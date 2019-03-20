class MANHATTAN_CONNECTION
	-- Represents a CONNECTION made up of MANHATTAN_SPANS.

	inherit
		CONNECTION
			rename
				make as connection_make
			redefine
				simplify_spans, make_new_span, finalize_placement,
				move_selected, move_source_by,
				set_decoration_orienter_for,
				make_for_reader,
				init_from_reader,
				name_for_writer
			select
				simplify_spans, finalize_placement, move_source_by
			end;
		CONNECTION
			rename
				make as connection_make,
				finalize_placement as connection_finalize_placement,
				move_source_by as connection_move_source_by,
				simplify_spans as connection_simplify_spans
			redefine
				make_new_span, move_selected,
				set_decoration_orienter_for,
				make_for_reader,
				init_from_reader,
				name_for_writer
			end;

creation

	make,
	make_for_reader

feature	-- Initialize/Release

	make (a_relationship : LM_RELATIONSHIP; a_diagram : DIAGRAM; 
		  a_source, a_destination : SOLID; 
	      some_spans : ARRAYED_LIST [SPAN]) is
		require
			all_spans_manhattan: spans_are_manhattan (some_spans)
		do
			connection_make(a_relationship, a_diagram, a_source, 
						    a_destination, some_spans);
		end;

feature		-- Modification

	move_source_by(dx, dy : INTEGER) is
		local
			span : MANHATTAN_SPAN;
			ep : SPAN_ENDPOINT;
		do
			if spans.count = 1 then
				span ?= (spans @ 1);
				if span.must_be_straight_line then
					ep := span.destination;
					ep.move_toward(ep.x + dx, ep.y + dy);
				end;
			end;  -- if
			connection_move_source_by(dx, dy);
		end;


	simplify_spans : BOOLEAN is
		local
			i : INTEGER;
			span1, span2, new_span : MANHATTAN_SPAN;
			done : BOOLEAN;
		do
			Result := False;
			from done := False until done loop
				done := True;
				from i := 1 variant spans.count-i until (i+1) > spans.count 
				loop
					span1 ?= spans @ i;
					span2 ?= spans @ (i+1);
					if span1.is_straight_line then
						if span2.is_straight_line then
							!!new_span.make(span1.source,span2.destination,
											span1.canvas, span1.is_vertical);
							if selected_span_index = i then
								new_span.set_source_selected;
							elseif selected_span_index = i+1 then
								new_span.set_destination_selected;
								selected_span_index := i;
							elseif selected_span_index > i+1 then
								selected_span_index := selected_span_index - 1;
							end
							span1.release;
							span2.release;
							spans.put_i_th(new_span, i);
							spans.go_i_th(i+1);
							spans.remove;
							Result := true;
						else
							span1.set_source_side_vertical(span1.is_vertical);
							span1.relax_span_constraints;
							if selected_span_index = (i+1)
								and then span2.source_is_selected
							then
								selected_span_index := i;
								span2.deselect;
								span1.set_destination_selected;
							elseif selected_span_index = i then
								span1.set_source_selected;
							end -- if
							span1.destination.move_toward(span2.midpoint_x, 
														  span2.midpoint_y);
							span1.note_moved_endpoints;
							span2.note_moved_endpoints;
							span2.set_source_side_vertical(not span2.is_horizontal);
							i := i + 1;
							Result := true;
						end;
					else
						i := i + 1
					end;
				end  -- loop
				if connection_simplify_spans then
					done := False
					Result := True
				end -- if
			end  -- loop
		end;

feature		-- Testing

	spans_are_manhattan (some_spans : ARRAYED_LIST [SPAN] ) : BOOLEAN is
		local
			i : INTEGER
			span : MANHATTAN_SPAN;
		do
			Result := True;
			from i:= 1 until i > some_spans.count loop
				span ?= some_spans @ i;
				if span = Void then
					Result := False;
				end;
				i := i + 1;
			end
		end;



feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str, lm_id_str : STRING;
			a_relationship : LM_RELATIONSHIP;
			src_str, dest_str : STRING;
			a_source, a_destination : SOLID;
			new_spans : ARRAYED_LIST [ SPAN ];
		do
			if args.count < 4 then
				reader.error("Incorrect number of arguments for manhattan-connection");
			end;
			id_str ?= args @ 1;
			lm_id_str ?= args @ 2;
			src_str ?= args @ 3;
			dest_str ?= args @ 4;
			if not spans_are_manhattan (reader.some_spans) then
				reader.error("Error in arguments arguments to manhattan-connection");
			end

			if not lm_id_str.is_equal("nil") then
				a_relationship ?= reader.get_lm_item(lm_id_str);
				if a_relationship = Void then
					reader.error("Error in arguments arguments to manhattan-connection");
				end
			end
			a_source ?= reader.get_diagram_drawable(src_str);
			a_destination ?= reader.get_diagram_drawable(dest_str);
			if a_source = Void or else a_destination = Void then
				reader.error("Error in arguments arguments to manhattan-connection");
			end

			new_spans := reader.take_some_spans;
			if (not (new_spans @ 1).source.is_constrained_to(a_source))
			   or else (not (new_spans @ new_spans.count).
						    	destination.is_constrained_to(a_destination))
			then
				reader.error("Spans incorrectly constrained in manhattan-connection");
			end;
			connection_make(a_relationship, Void, a_source, 
						    a_destination, new_spans);
				-- The diagram (the second arg) gets set in init_from_reader.

			reader.add_diagram_drawable(id_str, Current);
		end;

feature { DIAGRAM }		-- Streaming support

	init_from_reader (a_diagram : DIAGRAM) is
		local
			i : INTEGER;
		do
			from i := 1 until i > spans.count loop
				(spans @ i).init_from_Reader(a_diagram.canvas);
				i := i + 1;
			end -- loop
			set_diagram(a_diagram);
		end;


feature { CONNECTION }	-- Streaming Support

	name_for_writer : STRING is
		do
			Result := "manhattan-connection"
		end;



feature { MANHATTAN_CONNECTION } -- Implementation

	finalize_placement is
		local
			s : MANHATTAN_SPAN;
		do
			connection_finalize_placement;
			s ?= spans @ spans.count;
			if s.is_straight_line then
				s.set_must_be_straight_line;
			end -- if
		end;


	move_selected (dx, dy : INTEGER) is
		local
			the_span : MANHATTAN_SPAN;
			neighbor : MANHATTAN_SPAN;
			ep : SPAN_ENDPOINT;
			target_x, target_y : INTEGER;
			changed : BOOLEAN;
		do
			changed := False;
			the_span ?= selected_span;
			check span_selected : the_span /= Void end;
				-- We know this from the invariant and our precondition

			if the_span.must_be_straight_line then
				check is_last: selected_span_index = spans.count end;
				ep := the_span.source;
				if the_span.source_line_is_vertical then
					target_x := ep.x + dx;
					target_y := ep.y;
					ep.move_toward(target_x, target_y);
					if ep.x /=  target_x or else ep.y /= target_y then
						handle_source_off_end_of_solid(target_x, target_y);
						changed := True;
					end -- if
					ep := the_span.destination;
					target_x := ep.x + dx;
					target_y := ep.y;
				else
					target_x := ep.x;
					target_y := ep.y + dy;
					ep.move_toward(target_x, target_y);
					if ep.x /=  target_x or else ep.y /= target_y then
						handle_source_off_end_of_solid(target_x, target_y);
						changed := True;
					end -- if
					ep := the_span.destination;
					target_x := ep.x;
					target_y := ep.y + dy;
				end; -- if
				ep.move_toward(target_x, target_y);
				if ep.x /=  target_x or else ep.y /= target_y then
					handle_destination_off_end_of_solid(target_x, target_y);
					changed := True;
				end -- if
				if selected_span_index > 1 then
					neighbor ?= spans @ (selected_span_index - 1);
				end --  if
			elseif the_span.source_is_selected then
				ep := the_span.source;
				if the_span.source_side_vertical then
					target_x := ep.x + dx;
					target_y := ep.y;
				else
					target_x := ep.x;
					target_y := ep.y + dy;
				end; -- if
				ep.move_toward(target_x, target_y);
				if ep.x /=  target_x or else ep.y /= target_y then
					handle_source_off_end_of_solid(target_x, target_y);
					changed := True;
				end -- if
				if selected_span_index > 1 then
					neighbor ?= spans @ (selected_span_index - 1);
				end; -- if
			else
				check something_selected: the_span.destination_is_selected end;
				ep := the_span.destination;
				if the_span.source_side_vertical then
					target_x := ep.x;
					target_y := ep.y + dy;
				else
					target_x := ep.x + dx;
					target_y := ep.y;
				end; -- if
				ep.move_toward(target_x, target_y);
				if ep.x /=  target_x or else ep.y /= target_y then
					handle_destination_off_end_of_solid(target_x, target_y);
				end -- if
				if selected_span_index < spans.count then
					neighbor ?= spans @ (selected_span_index + 1);
				end; -- if
			end; -- if
			the_span.note_moved_endpoints;
			if neighbor /= Void then
				neighbor.note_moved_endpoints;
			end; -- if
			if changed then
				changed := simplify_spans;
			end
			check_selected_span_constraints;
			move_selection_rects;
		end;

	handle_source_off_end_of_solid (target_x, target_y : INTEGER) is
		-- handle the case where the source endpoint would fall off the
		-- end of the solid to which it's attached
		require
			is_source: selected_span_index = 1
		local
			the_span : MANHATTAN_SPAN;
			new_span : SPAN;
			line : LINE_SEGMENT;
			bb : BOUNDING_BOX;
			end_ep, mid_ep : SPAN_ENDPOINT;
		do
			the_span ?= selected_span;
			check source_selected: the_span.source_is_selected end;
			bb := source.bounding_box;
			!!line.make(bb.midpoint_x, bb.midpoint_y, target_x, target_y);
			end_ep := source.endpoint_intersection_with_line(line);
			check ep_created: end_ep /= Void end;
			if the_span.source.y /= target_y then
				!!mid_ep.make(end_ep.x, target_y);	-- make a veritcal line
			else
				!!mid_ep.make(target_x, end_ep.y);	-- make a horizontal line
			end
			new_span := make_new_span(end_ep, mid_ep, the_span.canvas);
			the_span.set_source(mid_ep);
			spans.put_front(new_span);
			selected_span_index := selected_span_index + 1;
		ensure
			selected_span_same: old selected_span = selected_span
		end;


	handle_destination_off_end_of_solid (target_x, target_y : INTEGER) is
		-- handle the case where the destination endpoint would fall off the
		-- end of the solid to which it's attached
		require
			is_destination : selected_span_index = spans.count
		local
			the_span : MANHATTAN_SPAN;
			new_span : SPAN;
			line : LINE_SEGMENT;
			bb : BOUNDING_BOX;
			end_ep, mid_ep : SPAN_ENDPOINT;
		do
			the_span ?= selected_span;
			check destination_selected: the_span.destination_is_selected end;
			bb := destination.bounding_box;
			!!line.make(bb.midpoint_x, bb.midpoint_y, target_x, target_y);
			end_ep := destination.endpoint_intersection_with_line(line);
			check ep_created: end_ep /= Void end;
			if the_span.destination.y /= target_y then
				!!mid_ep.make(end_ep.x, target_y);	-- make a veritcal line
			else
				!!mid_ep.make(target_x, end_ep.y);	-- make a horizontal line
			end
			new_span := make_new_span(mid_ep, end_ep, the_span.canvas);
			the_span.set_destination(mid_ep);
			spans.extend(new_span);
		ensure
			selected_span_same: old selected_span = selected_span
		end;


	check_selected_span_constraints is
			-- Check the constraints on the selected span, and if they're 
			-- not satisfied, try to put the connection in a state that 
			-- will satisfy them.  If this isn't possible, that's 
			-- OK -- connections are allowed  to be in an inconsistent 
			-- state temporarily.
		local
			the_span : MANHATTAN_SPAN;
			src_v, dest_v : BOOLEAN;
			bb : BOUNDING_BOX;
			line : LINE_SEGMENT;
			other_ep, new_ep : SPAN_ENDPOINT;
			x, y : INTEGER;
			changed : BOOLEAN;
		do
			the_span ?= selected_span;
			src_v := (spans @ 1).source
							.span_violates_constraints(spans @ 1) 
			dest_v := (spans @ spans.count).destination
							.span_violates_constraints(spans @ spans.count) 
			if src_v and dest_v then
				-- do nothing...  This case is rare, difficult, and not
				-- very important
			elseif src_v and selected_span_index = 1 then
				x := the_span.destination.x;
				y := the_span.destination.y;
				if not source.contains(x, y) then
					bb := source.bounding_box;
					!!line.make(bb.midpoint_x, bb.midpoint_y, x, y);
					new_ep := source.endpoint_intersection_with_line(line);
					new_ep.move_toward(x, y);
					the_span.set_source(new_ep);
					if the_span.is_straight_line then
						the_span.set_source_selected;
						the_span.set_must_be_straight_line;
					else
						the_span.set_destination_selected;
					end;
					the_span.note_moved_endpoints;
					changed := simplify_spans;
				end;
			elseif dest_v and selected_span_index = spans.count then
				x := the_span.source.x;
				y := the_span.source.y;
				if not destination.contains(x, y) then
					bb := destination.bounding_box;
					!!line.make(bb.midpoint_x, bb.midpoint_y, x, y);
					new_ep := destination.endpoint_intersection_with_line(line);
					new_ep.move_toward(x, y);
					the_span.set_destination(new_ep);
					if the_span.is_straight_line then
						the_span.set_destination_selected;
						the_span.set_must_be_straight_line;
					else
						the_span.set_source_selected;
					end;
					the_span.note_moved_endpoints;
					changed := simplify_spans;
				end;
			elseif dest_v and then selected_span_index = (spans.count - 1) then
				x := the_span.midpoint_x;
				y := the_span.midpoint_y;
				bb := destination.bounding_box;
				if not destination.contains(x, y) then
					if destination.contains(the_span.destination.x, 
										    the_span.destination.y) 
					then
						(spans @ spans.count).release;
						spans.go_i_th(spans.count);
						spans.remove;
						!!line.make(bb.midpoint_x, bb.midpoint_y, x, y);
						new_ep 
						   := destination.endpoint_intersection_with_line(line);
						new_ep.move_toward(x, y);
						the_span.set_destination(new_ep);
						the_span.note_moved_endpoints;
						changed := simplify_spans;
					else	
						-- We've moved all the way to the other side 
						-- of the solid
						x := the_span.destination.x;
						y := the_span.destination.y;
						!!line.make(bb.midpoint_x, bb.midpoint_y, x, y);
						new_ep := destination
									.endpoint_intersection_with_line(line);
						new_ep.move_toward(x, y);
						(spans @ spans.count).set_destination(new_ep);
						(spans @ spans.count).note_moved_endpoints;
						changed := simplify_spans;
					end  -- if
				end
			end   -- The corresponding "src_v and then selected_span_index = 2"
				  -- cannot happen because of the way we simplify spans.
		end;

	make_new_span(source_ep, dest_ep : SPAN_ENDPOINT;
				  a_canvas : TK_CANVAS) : SPAN is
		local
			source_vertical : BOOLEAN;
		do
			source_vertical := source_ep.requires_vertical_spans
							   or else dest_ep.requires_horizontal_spans;
			!MANHATTAN_SPAN!Result.make(source_ep, dest_ep, a_canvas,
										source_vertical);
		end;

	endpoints_are_shared : BOOLEAN is
		-- Do all of our spans share endpoints between them?
		-- (they'd better :-)
		local
			i : INTEGER;
			ep : SPAN_ENDPOINT;
		do
			Result := True;
			if spans.count > 2 then
				ep := (spans @ 1).destination;
				from i := 2 until (not Result) or else (i > spans.count) loop
					Result := ep = (spans @ i).source;
					ep := (spans @ i).destination;
					i := i + 1;
				end; -- loop
			end; -- if
		end;

	set_decoration_orienter_for (decoration : CONNECTION_DECORATION;
								 span : SPAN;
								 endpoint : SPAN_ENDPOINT) is
			-- Sets the orienter for decoration, according to the kind
			-- of spans we contain, the span coming from the decoration
			-- and/or the endpoint the decoration is attached to.
		local
			constraint : ENDPOINT_SOLID_CONSTRAINT;
			orienter : DECORATION_ORIENTER;
		do
			constraint ?= endpoint.constraint;
			check has_constraint: constraint /= Void end;
				-- Either end of a Manhattan constraint must necessarily
				-- be constrained to the side of a solid.

			orienter := constraint.decoration_orienter;
				-- Endpoint solid constraints know how to deliver an
				-- orienter appropriate to the solid side they represent.

			decoration.set_orienter(orienter);
		end;


invariant

	all_spans_manhattan:  spans_are_manhattan (spans);
	endpoints_are_shared: endpoints_are_shared;


end	-- class MANHATTAN_CONNECTION
