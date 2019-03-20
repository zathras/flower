deferred class CONNECTION 
	-- Represents something that connects two solids.  A CONNECTION
	-- is what represents a RELATIONSHIP on a DIAGRAM.

	-- @@ To do:  It would be nice if the decorations could be 
	-- @@		  dragged around (or even gotten rid of) during
	-- @@		  a drag.
inherit

	DRAWABLE
		redefine
			bounding_box, deselect, single_select, attempt_multiple_select, 
			contains, supports_direct_drag, finalize_placement,
			logical_model_item, set_diagram,
			write_for_writer
		select
			set_diagram
		end;
	DRAWABLE
		rename
			set_diagram as drawable_set_diagram
		redefine
			bounding_box, deselect, single_select, attempt_multiple_select, 
			contains, supports_direct_drag, finalize_placement,
			logical_model_item,
			write_for_writer
		end;
	OBSERVER	-- To observe our relationship
		redefine
			notify_change,
			notify_release
		end;


feature		-- Initialize/Release


	make (a_relationship : LM_RELATIONSHIP; a_diagram : DIAGRAM; 
	      a_source, a_destination : SOLID; 
		  some_spans : ARRAYED_LIST [SPAN]) is
		-- The CONNECTION takes over ownership of some_spans.  some_spans
		-- must run from source to destination.
		require
			nonempty_spans : some_spans.count > 0;
			endpoints_correctly_constrained:
				(some_spans @ 1).source.is_constrained_to(a_source)
				and then (some_spans @ some_spans.count).
								destination.is_constrained_to(a_destination);
		do
			init_drawable(a_diagram);
			relationship := a_relationship;
			spans := some_spans;
			source := a_source;
			destination := a_destination;
			selected_span_index := 0;
			source.add_connection(Current);
			destination.add_connection(Current);
			if diagram /= Void then
				do_diagram_initialization;
			end;
		end;


feature { CONNECTION }		-- Protected initialization


	do_diagram_initialization is
		require
			diagram_set : diagram /= Void
		do
			!!selection_rect_1.make(diagram.canvas);
			selection_rect_1.set_fill_color("black");
			!!selection_rect_2.make(diagram.canvas);
			selection_rect_2.set_fill_color("black");
			if relationship /= Void then
				notify_change;	-- In case relationship has decorations
				relationship.add_observer(Current);
			end -- if
			finalize_placement;
		end;

	set_diagram (d : DIAGRAM) is
		do
			drawable_set_diagram(d);
			do_diagram_initialization;
		end;


feature		-- Querying


	supports_direct_drag : BOOLEAN is
		do
			Result := True;
		end;

	bounding_box : BOUNDING_BOX is
		local
			x, y : INTEGER;
			i : INTEGER;
		do
			x := (spans @ 1).source.x;
			y := (spans @ 1).source.y;
			!!Result.make(x, y, 0, 0);
			from i := 1 until i > spans.count loop
				x := (spans @ i).destination.x;
				y := (spans @ i).destination.y;
				Result.expand_to_include(x, y);
				i := i + 1;
			end;  -- loop
		end;

	contains (x, y : INTEGER) : BOOLEAN is
		local
			i : INTEGER;
		do
			Result := False;
			from i := 1 until Result or else i > spans.count loop
				if (spans @ i).contains(x, y) then
					Result := True;
				end -- if
				i := i + 1;
			end;
		end;

feature		-- Modification


	move (dx, dy : INTEGER) is
			-- Move the entire connection.  All endpoints that are selected 
			-- were moved by (dx, dy), and at least one endpoint was moved.
		do
			if source.selected and then destination.selected then
				simple_move(dx, dy);
			else
				complex_move(dx, dy);
			end;
			move_selection_rects;
		end;

	single_select (x, y : INTEGER) is
		local
			i : INTEGER;
		do
			deselect;
			check not_selected: selected_span_index = 0 end;
			from i := 1 
			until selected_span_index /= 0 or else i > spans.count 
			loop
				if (spans @ i).contains(x, y) then
					selected_span_index := i;
					selected_span.select_it(x, y);
				end; -- if
				i := i + 1;
			end;
			check span_found: selected_span /= Void end;
				-- This is true because of the contains precondition we
				-- inherit from DRAWABLE>>single_select.

			selected_span.select_it(x, y);
			selected := True;
			move_selection_rects;
		end;

	attempt_multiple_select is
			-- Connections can *not* be selected as part of a multiple
			-- selection.  If the user isn't dragging just the connection,
			-- then the connection moves with its endpoints.
		do
			deselect
		end;

	deselect is
		do
			if selected_span /= Void then
				selected_span.deselect
				selected_span_index := 0;
			end;
			selected := False;
			move_selection_rects;
		end;


	finalize_placement is
			-- Called when a connection has been put where it will stay in the
			-- diagram.  This routine should not change the outward appearance
			-- of the connecition, unless the connection violates one of
			-- its constraints.
		local
			x, y : INTEGER;
			done : BOOLEAN;
		do
			relax_connection_constraints;
			from done := false until done loop
				enforce_source_constraints;		
				done := not simplify_spans;
			end; -- loop
			if spans.count > 1
				and then (spans @ spans.count).constraint_violated
			then
				mirror;
				from done := false until done loop
					enforce_source_constraints;		
					done := not simplify_spans;
				end; -- loop
			end;  -- if
			if (source = destination)
			   and then (Current.contained_within(source.bounding_box))
			then
				replace_entire_chain;
				done := not simplify_spans;
			end;  -- if
			move_selection_rects;
			apply_decorations;	-- They may have become detached
			place_decorations;
		end;

	note_moved_solids is
			-- Notice when the solids at our endpoints might have moved.  
			-- This could happen because the object at our source or 
			-- our destination has changed size.
		local
			ep : SPAN_ENDPOINT;
		do
			ep := (spans @ 1).source;
			ep.move_toward(ep.x, ep.y);  -- Forces it within constraints
			if spans.count > 1 then
				(spans @ 1).note_moved_endpoints
			end
			ep := (spans @ spans.count).destination;
			ep.move_toward(ep.x, ep.y);
			(spans @ spans.count).note_moved_endpoints;
			finalize_placement;
		end;

	simplify_spans : BOOLEAN is
			-- Simplify the spans that make up this connection.  Return True
			-- if something was modified.  If there is a selected_span,
			-- try to maintain it (this might be impossible, however).
		local
			i : INTEGER;
			span1, span2 : SPAN;
		do
			Result := False;
			from i := 1 until (i+1) > spans.count loop
				span1 := spans @ i;
				span2 := spans @ (i+1);
				if span1.merge_colinear_part(span2) then
					Result := true;
				end;
				if span1.source.coincides_with(span1.destination) then
					if selected_span_index = i then
						if span2.transfer_selection_from(span1) then
							-- do nothing... span 2 will move to position i
						elseif i > 1 
							and then (spans @ (i-1))
										.transfer_selection_from(span1)
						then
							selected_span_index := i - 1
						else
							deselect;
						end -- if
					elseif selected_span_index > i then
						selected_span_index := selected_span_index - 1;
					end -- if
					span2.set_source(span1.source);
					span1.release;
					span2.note_moved_endpoints;
					spans.go_i_th(i);
					spans.remove;
					Result := true;
				end  -- if
				i := i + 1;
			end -- loop
			if spans.count > 1 then		-- Check the final span
				span1 := spans @ (spans.count - 1);
				span2 := spans @ (spans.count);
				if span2.source.coincides_with(span2.destination) then
					if selected_span_index = spans.count then
						if span1.transfer_selection_from(span2) then
							selected_span_index := selected_span_index - 1;
						else
							deselect;
						end -- if
					end -- if
					span1.set_destination(span2.destination);
					span2.release;
					span1.note_moved_endpoints;
					spans.go_i_th(spans.count);
					spans.remove;
					Result := true;
				end -- if
			end -- if
		end;

feature		-- Attributes

	relationship : LM_RELATIONSHIP;		-- Might be Void

	source_decoration : CONNECTION_DECORATION;
	destination_decoration : CONNECTION_DECORATION;
	
feature		-- Querying

	logical_model_item : LOGICAL_MODEL_ITEM is
		do
			Result := relationship
		end;

feature	{ OBSERVER, OBSERVABLE }	-- Notification

	-- These features are invoked when the relationship we're observing
	-- changes.


	notify_change is
		local
			reversed : BOOLEAN;
		do
			reversed := relationship.source = destination.logical_model_item
						or else relationship.destination 
												= source.logical_model_item;

			if reversed then
				if not relationship.destination_decoration_ok
										(diagram, source_decoration) 
				then
					if source_decoration /= Void then
						source_decoration.release;
					end
					source_decoration
						:= relationship.make_destination_decoration(diagram);
				end
				if not relationship.source_decoration_ok
											(diagram, destination_decoration) 
				then
					if destination_decoration /= Void then
						destination_decoration.release;
					end
					destination_decoration
						:= relationship.make_source_decoration(diagram);
				end
			else
				if not relationship
							.source_decoration_ok(diagram, source_decoration) 
				then
					if source_decoration /= Void then
						source_decoration.release;
					end
					source_decoration
						:= relationship.make_source_decoration(diagram);
				end
				if not relationship.destination_decoration_ok
											(diagram, destination_decoration) 
				then
					if destination_decoration /= Void then
						destination_decoration.release;
					end
					destination_decoration
						:= relationship.make_destination_decoration(diagram);
				end
			end

			apply_decorations;
			place_decorations;
		end;

	notify_release is
		do
			-- @@ Implement this
		end;

feature { CONNECTION }	-- Streaming Support

	name_for_writer : STRING is
		deferred
		end;

feature { NONE }		-- Streaming Support

	check_write_span_endpoint (writer : PROJECT_WRITER; ep : SPAN_ENDPOINT) is
		do
			if not writer.has_span_endpoint(ep) then
				ep.write_for_writer(writer);
				check registered: writer.has_span_endpoint(ep) end;
			end
		end;

feature { DIAGRAM }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			i : INTEGER;
			ep : SPAN_ENDPOINT;
		do
			writer.left_paren;
			writer.write_token(name_for_writer);
			writer.write_integer(writer.get_connection_id(Current));
			if relationship = Void then
				writer.write_token("nil")
			else
				writer.write_integer(writer.get_lm_id(relationship));
			end
			writer.write_integer(writer.get_drawable_id(source));
			writer.write_integer(writer.get_drawable_id(destination));
			writer.new_line;

			from i := 1 until i > spans.count loop
				check_write_span_endpoint(writer, (spans @ i).source);
				check_write_span_endpoint(writer, (spans @ i).destination);
				i := i + 1;
			end

			from i := 1 until i > spans.count loop
				(spans @ i).write_for_writer(writer);
				i := i + 1;
			end
			writer.right_paren;
			writer.new_line;
			writer.reset_span_endpoints;
		end;


	init_from_reader (a_diagram : DIAGRAM) is
		local
			i : INTEGER;
		do
			from i := 1 until i > spans.count loop
				(spans @ i).init_from_reader(diagram.canvas);
			end -- loop
		end;


feature { CONNECTION }	-- Implementation

	spans : ARRAYED_LIST [SPAN];

	selected_span_index : INTEGER;
		-- The index of the currently selected span, or 0 if none is.

	source, destination : SOLID;
		-- spans runs from source to destination

	selection_rect_1, selection_rect_2 : CANVAS_RECT;
		-- Small rectangles for indicating the endpoints of a selected 
		-- connection

	selected_span : SPAN is
		-- The span that's currently selected, if one is.
		do
			if selected_span_index = 0 
				or else selected_span_index > spans.count
			then
				Result := Void
			else
				Result := spans @ selected_span_index
			end; -- if
		end;

	source_endpoint : SPAN_ENDPOINT is
		do
			Result := (spans @ 1).source;
		end;

	destination_endpoint : SPAN_ENDPOINT is
		do
			Result := (spans @ spans.count).destination;
		end;


	move_selection_rects is
		local
			x1, y1, x2, y2 : INTEGER;
		do
			x1 := (spans @ 1).source.x;
			y1 := (spans @ 1).source.y;
			x2 := (spans @ spans.count).destination.x;
			y2 := (spans @ spans.count).destination.y;
			if selected then
				selection_rect_1.set_coords(x1 - 3, y1 - 3, x1 + 2, y1 + 2);
				selection_rect_2.set_coords(x2 - 3, y2 - 3, x2 + 2, y2 + 2);
			else
				selection_rect_1.set_coords(-10, -10, -10, -10);
				selection_rect_2.set_coords(-10, -10, -10, -10);
			end;
		end;

	relax_connection_constraints is
			-- Relax any connection-specific constraints (but *not* any
			-- endpoint constraints).  Called when the connection is
			-- about to be re-created.
		local
			i : INTEGER;
		do
			from i := 1 until i > spans.count loop
				(spans @ i).relax_span_constraints;
				i := i + 1;
			end;
		end;

	connection_constraint_violated : BOOLEAN is 
			-- Are any connection-specific constrains violated?
		do
			Result := False;
		end;

	simple_move(dx, dy : INTEGER) is
			-- Do a move where all endpoints are moving
		local
			i : INTEGER;
			ep : SPAN_ENDPOINT;
		do
				-- Move all endpoints
			ep := (spans @ 1).source;
			ep.move_toward(ep.x + dx, ep.y + dy);
			from i := 1 until i > spans.count loop
				ep := (spans @ i).destination
				ep.move_toward(ep.x + dx, ep.y + dy);
				i := i + 1;
			end;

				-- Now tell the spans to conform to their endpoints
			from i := 1 until i > spans.count loop
				(spans @ i).note_moved_endpoints;
				i := i + 1;
			end;

			place_decorations;
		end;

	complex_move(dx, dy : INTEGER) is
			-- Do a move where not all endpoints are moving
		local
			i : INTEGER;
		do
			if not source.selected then
				mirror
			end;
			check one_selected: source.selected end;
			move_source_by(dx, dy);
			enforce_source_constraints;
			finalize_placement;
		end;

	move_source_by(dx, dy : INTEGER) is
		local
			span : SPAN;
			ep : SPAN_ENDPOINT;
		do
			span := spans @ 1;
			ep := span.source;
			ep.move_toward(ep.x + dx, ep.y + dy);
			span.note_moved_endpoints;
		end;

	enforce_source_constraints is 
		local
			ep : SPAN_ENDPOINT;
		do
			if connection_constraint_violated
			   or else (spans @ 1).constraint_violated 
		    then
				ep := (spans @ 1).destination;
				if spans.count <= 1 then
					replace_entire_chain
				elseif source.bounding_box.contains(ep.x, ep.y) then
					trim_source_span
				else
					replace_first_span;
				end;
			end;
		end;

	replace_first_span is
			-- The constraint was violated for the first span, but it's just
			-- connected to a fixed point that's not contained within the
			-- source solid.  We can safely make a span from ourselves
			-- to it.
		local
			line : LINE_SEGMENT;
			ep, new_ep : SPAN_ENDPOINT;
			bb : BOUNDING_BOX;
			new_span : SPAN;
		do
			ep := (spans @ 1).destination;
			bb := source.bounding_box;
			!!line.make(bb.midpoint_x, bb.midpoint_y, ep.x, ep.y);
			new_ep := source.endpoint_intersection_with_line(line);
			check endpoint_found: new_ep /= Void end;
			new_span := make_new_span(new_ep, ep, (spans @ 1).canvas);
			(spans @ 1).release;
			spans.put_i_th(new_span, 1);
		end;

	trim_source_span is
		-- Get rid of one span on the source side
		do
			if spans.count <= 1 then
				replace_entire_chain
			else
				(spans @ 2).set_source((spans @ 1).source);
				(spans @ 1).release;
				spans.go_i_th(1);
				spans.remove;
				(spans @ 1).note_moved_endpoints;
				enforce_source_constraints;
			end -- if
		end -- do

	replace_entire_chain is
		-- This connection can't be salvaged, so we just try to come up with
		-- something reasonable.
		local
			i : INTEGER;
			line : LINE_SEGMENT;
			x, y : INTEGER;
			source_ep, dest_ep, mid_ep : SPAN_ENDPOINT;
			source_bb, dest_bb : BOUNDING_BOX;
			new_span : SPAN;
			canvas : TK_CANVAS;
		do
			canvas := (spans @ 1).canvas;
			from i := 1 until i > spans.count loop
				(spans @ i).release;
				i := i + 1;
			end  -- loop
			spans.wipe_out;
			source_bb := source.bounding_box;
			dest_bb := destination.bounding_box;
			!!line.make(source_bb.midpoint_x, source_bb.midpoint_y, 
						dest_bb.midpoint_x, dest_bb.midpoint_y);
			source_ep := source.endpoint_intersection_with_line(line);
			dest_ep := destination.endpoint_intersection_with_line(line);
			if source_ep = Void or else dest_ep = Void then
				create_looped_chain(canvas);
			else
				if source_ep.requires_horizontal_spans 
					/= dest_ep.requires_horizontal_spans
				then
					new_span := make_new_span(source_ep, dest_ep, canvas);
					spans.extend(new_span);
				else
					!!mid_ep.make((source_ep.x + dest_ep.x) // 2,
								  (source_ep.y + dest_ep.y) // 2);
					if source_ep.requires_horizontal_spans then
						if mid_ep.y >= source_bb.top
						   and then mid_ep.y <= source_bb.bottom
						   and then mid_ep.y >= dest_bb.top
						   and then mid_ep.y <= dest_bb.bottom
						then
						   source_ep.move_toward(mid_ep.x, mid_ep.y);
						   dest_ep.move_toward(mid_ep.x, mid_ep.y);
						end
					else	-- Vertical spans
						if mid_ep.x >= source_bb.left
						   and then mid_ep.x <= source_bb.right
						   and then mid_ep.x >= dest_bb.left
						   and then mid_ep.x <= dest_bb.right
						then
						   source_ep.move_toward(mid_ep.x, mid_ep.y);
						   dest_ep.move_toward(mid_ep.x, mid_ep.y);
						end
					end -- if
					new_span := make_new_span(source_ep, mid_ep, canvas);
					spans.extend(new_span);
					new_span := make_new_span(mid_ep, dest_ep, canvas);
					spans.extend(new_span);
					if (spans @ 1).constraint_violated 
						or else (spans @ 2).constraint_violated
					then
						(spans @ 1).release;
						(spans @ 2).release;
						spans.wipe_out;
						create_looped_chain(canvas);
					end -- if
				end -- if
			end  -- if
		end;

	create_looped_chain (canvas : TK_CANVAS) is
		-- This is invoked by replace_entire_chain in desperation, when it
		-- fails to make a reasonable chain.  This might happen because, for
		-- example, one class box is contained within another.  This routine
		-- does something ugly that's guaranteed to work.
		local
			x, y : INTEGER;
			tmp_solid : SOLID;
			source_ep, dest_ep : SPAN_ENDPOINT;
			source_bb, dest_bb : BOUNDING_BOX;
			line : LINE_SEGMENT;
			new_span : SPAN;
		do
			if (source.bounding_box.midpoint_x 
					> destination.bounding_box.midpoint_x)
			then
				tmp_solid := source;
				source := destination;
				destination := tmp_solid;
			end;
			source_bb := source.bounding_box;
			dest_bb := destination.bounding_box;
			x := source_bb.midpoint_x;
			y := (source_bb.top.min(dest_bb.top)) - 20;
			!!line.make(source_bb.midpoint_x, source_bb.midpoint_y, x, y);
			source_ep := source.endpoint_intersection_with_line(line);
			check source_ok : source_ep /= Void end;
			!!dest_ep.make(x, y);
			new_span := make_new_span(source_ep, dest_ep, canvas);
			spans.extend(new_span);

			source_ep := dest_ep;
			x := dest_bb.right.max(source_bb.right) + 20;
			!!dest_ep.make(x, y);
			new_span := make_new_span(source_ep, dest_ep, canvas);
			spans.extend(new_span);

			source_ep := dest_ep;
			y := dest_bb.midpoint_y;
			!!dest_ep.make(x, y);
			new_span := make_new_span(source_ep, dest_ep, canvas);
			spans.extend(new_span);

			source_ep := dest_ep;
			!!line.make(dest_bb.midpoint_x, dest_bb.midpoint_y, x, y);
			dest_ep := destination.endpoint_intersection_with_line(line);
			check dest_ok : dest_ep /= Void end;
			new_span := make_new_span(source_ep, dest_ep, canvas);
			spans.extend(new_span);
		end;

	mirror is
			-- Move our source to our destination, and then simplify.
			-- This is valuable because simplifying always guarantees
			-- that the *source* side's span takes as much responsibility
			-- as possible.
		local
			i : INTEGER;
			tmp_span : SPAN;
			tmp_solid : SOLID;
			tmp_decoration : CONNECTION_DECORATION;
			modified : BOOLEAN;
		do
			from i := 1 until i > (spans.count // 2) loop
				tmp_span := spans @ i;
				spans.put_i_th(spans @ (spans.count - i + 1), i);
				spans.put_i_th(tmp_span, spans.count - i + 1);
				i := i + 1;
			end; -- loop
			from i := 1 until i > spans.count loop
				(spans @ i).mirror;
				i := i + 1;
			end; -- loop
			tmp_solid := source;
			source := destination;
			destination := tmp_solid;
			tmp_decoration := source_decoration;
			source_decoration := destination_decoration;
			destination_decoration := tmp_decoration;
			modified := simplify_spans;
		end;


	make_new_span(source_ep, dest_ep : SPAN_ENDPOINT;
			      a_canvas : TK_CANVAS ) : SPAN is
		deferred
		end;

	contained_within(bb : BOUNDING_BOX) : BOOLEAN is
		-- Is this connection completely contained within the given
		-- bounding box?
		local
			i : INTEGER;
			ep : SPAN_ENDPOINT;
		do
			if spans.count = 0 then
				Result := True;
			else
				ep := (spans @ 1).source;
				Result := bb.contains(ep.x, ep.y);
				from i := 1 until Result = False or else i > spans.count loop
					ep := (spans @ i).destination;
					if not bb.contains(ep.x, ep.y) then
						Result := False
					end;
					i := i + 1;
				end; -- loop
			end; -- if;
		end;

	apply_decorations is
			-- Apply whatever decorations have been asked for at the 
			-- endpoints of the connection, and place them appropriately.
		do
			if source_decoration /= Void then
				source_decoration.set_endpoint(source_endpoint);
				set_decoration_orienter_for(source_decoration, 
										    spans @ 1, source_endpoint);
			end
			(spans @ 1).note_moved_endpoints;
			if destination_decoration /= Void then
				destination_decoration.set_endpoint(destination_endpoint);
				set_decoration_orienter_for(destination_decoration, 
										    spans @ spans.count, 
										    destination_endpoint);
			end
			(spans @ spans.count).note_moved_endpoints;
		end;

	place_decorations is
		do
			if source_decoration /= Void then
				source_decoration.place_items;
			end
			if destination_decoration /= Void then
				destination_decoration.place_items;
			end
		end;

	set_decoration_orienter_for (decoration : CONNECTION_DECORATION;
								 span : SPAN;
								 endpoint : SPAN_ENDPOINT) is
			-- Sets the orienter for decoration, according to the kind
			-- of spans we contain, the span coming from the decoration
			-- and/or the endpoint the decoration is attached to.
		deferred
		end;


invariant

	selection_consistent:  selected = (selected_span_index /= 0)
							and then selected = (selected_span /= Void);


end -- class CONNECTION
