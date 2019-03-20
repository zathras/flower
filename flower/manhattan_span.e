class MANHATTAN_SPAN
	-- Represents a span that consists of two lines, one horizontal and
	-- one vertical.  (Either line may be zero length)


inherit

	SPAN
		redefine
			move_destination,
			note_moved_endpoints,
			merge_colinear_part,
			mirror,
			release,
			midpoint_x,
			midpoint_y,
			is_straight_line,
			contains,
			select_it,
			transfer_selection_from,
			deselect,
			relax_span_constraints,
			constraint_violated,
			make_for_reader,
			init_from_reader,
			write_for_writer
		select
			mirror, relax_span_constraints, constraint_violated
		end;
	SPAN
		rename
			mirror as span_mirror,
			relax_span_constraints as span_relax_span_constraints,
			constraint_violated as span_constraint_violated
		end

creation

	make,
	make_for_reader

feature		-- Initialize/Release


	make (a_source : SPAN_ENDPOINT; a_destination : SPAN_ENDPOINT;
		  a_canvas : TK_CANVAS;
		  a_source_side_vertical : BOOLEAN) is
		do
			set_source(a_source);
			set_destination(a_destination);
			must_be_straight_line := False;
			source_side_vertical := a_source_side_vertical;
			if a_canvas /= Void then
				do_canvas_init(a_canvas);
			end
		end;


	do_canvas_init,
	init_from_reader (a_canvas : TK_CANVAS) is
			-- If the span was initialized without a canvas, do the
			-- deferred initialization here.
		do
			set_canvas(a_canvas);
			!!source_line.make(canvas);
			source_line.set_width(2);
			!!destination_line.make(canvas);
			destination_line.set_width(2);
			set_positions;
		end;


	release is
		do
			source_line.release;
			destination_line.release
		end;

feature				-- Modification


	move_destination (x : INTEGER; y : INTEGER) is
		do
			source.move_toward(x, y);
			destination.move_toward(x, y);
			set_positions;
		end;

	note_moved_endpoints is
		do
			set_positions;
		end;

	set_destination_endpoint(ep : SPAN_ENDPOINT) is
			-- Set the destination endpoint to ep, which might
			-- have different constraints than the old one.
		do
			source.move_toward(ep.x, ep.y);
			destination := ep;
			set_positions;
		end;

	set_source_side_vertical (a_boolean : BOOLEAN) is
			-- Maintain selectedness state in the bargain
		do
			if source_side_vertical /= a_boolean then
				if selection_state = source_selected_state then
					selection_state := destination_selected_state
				elseif selection_state = destination_selected_state then
					selection_state := source_selected_state
				end
				source_side_vertical := a_boolean;
				set_positions;
			end -- if
		end;

	merge_colinear_part(other : like Current) : BOOLEAN is
		local
			old_x, old_y : integer;
		do
			old_x := destination.x;
			old_y := destination.y;
			if destination_line_is_vertical 
			   and then other.source_line_is_vertical
			then
				source_side_vertical := False;
				destination.move_toward(destination.x, other.destination.y);
				note_moved_endpoints;
				other.note_moved_endpoints;
			elseif destination_line_is_horizontal
			   	   and then other.source_line_is_horizontal
			then
				source_side_vertical := True;
				destination.move_toward(other.destination.x, destination.y);
				note_moved_endpoints;
				other.note_moved_endpoints;
			end
			Result := destination.x /= old_x
					  or else destination.y /= old_y;
		end;


	mirror is
		do
			source_side_vertical := not source_side_vertical;
			if source_must_be_horizontal then	-- We haven't swapped yet!
				source_side_vertical := True;
			elseif source_must_be_vertical then
				source_side_vertical := False
			end;
			span_mirror;
		end;

	relax_span_constraints is
		do
			span_relax_span_constraints;
			must_be_straight_line := False;
		end;

	constraint_violated : BOOLEAN is
		do
			Result := span_constraint_violated
					  or else (must_be_straight_line and then 
					  				(not is_straight_line));
		end;

	set_must_be_straight_line is
		do
			must_be_straight_line := True;
		end;

	transfer_selection_from (other : like current) : BOOLEAN is
		local
			select_vertical, select_horizontal : BOOLEAN;
		do
			select_vertical := False;
			select_horizontal := False;
			if destination = other.source
			   and then other.source_is_selected
			then
				if destination_line_is_vertical 
				      and then other.source_line_is_vertical
				then
					select_vertical := True;
				elseif destination_line_is_horizontal
						   and then other.source_line_is_horizontal
				then
					select_horizontal := True;
				end; -- if
		    elseif source = other.destination
				and then other.destination_is_selected
			then
				if source_line_is_vertical
					and then other.destination_line_is_vertical
				then
					select_vertical := True;
				elseif source_line_is_horizontal
						and then other.destination_line_is_horizontal
				then
					select_horizontal := True;
				end; -- if
			end; -- if
			if select_vertical then
				Result := True;
				other.deselect;
				if source_side_vertical then
					set_source_selected;
				else
					set_destination_selected;
				end; -- if
			elseif select_horizontal then
				Result := True;
				other.deselect;
				if source_side_vertical then
					set_destination_selected;
				else
					set_source_selected;
				end; -- if
			else
				Result := False;
			end; -- if
		end;


feature		-- Querying

    source_side_vertical : BOOLEAN;        
    	-- Otherwise it's horizontal.  This reflects whether the source side
    	-- is *intended* to be vertical.  If the source_line has zero length,
    	-- the source side might not *be* vertical

	source_line_is_horizontal : BOOLEAN is
			-- Is the line from the source horizontal?
		do
			if source.x = destination.x then
				Result := False;
			elseif source.y = destination.y then
				Result := True;
			else
				Result := not source_side_vertical;
			end;
		end;

	source_line_is_vertical : BOOLEAN is
			-- Is the line leading from the source vertical?
		do
			if source.y = destination.y then
				Result := False;
			elseif source.x = destination.x then
				Result := True;
			else
				Result := source_side_vertical;
			end;
		end;


	destination_line_is_horizontal : BOOLEAN is
			-- Is the line leading to the destination horizontal?
		do
			if source.x = destination.x then
				Result := False;
			elseif source.y = destination.y then
				Result := True;
			else
				Result := source_side_vertical;
			end;
		end;

	destination_line_is_vertical : BOOLEAN is
			-- Is the line leading to the destination vertical?
		do
			if source.y = destination.y then
				Result := False;
			elseif source.x = destination.x then
				Result := True;
			else
				Result := not source_side_vertical;
			end;
		end;

    midpoint_x : INTEGER;
    midpoint_y : INTEGER;

    must_be_straight_line : BOOLEAN;
    	-- Is this span constrained to be a straight line?

	is_straight_line : BOOLEAN is
			-- Is this span a straight line?  
		do
			Result := (source.y = destination.y)
					  or else (source.x = destination.x);
		end  -- do


	contains (x, y : INTEGER) : BOOLEAN is
			-- Is the point x,y within selection_slop of a line that 
			-- represents this connection?
		do
			result := source_line_contains(x, y)
					  or else destination_line_contains(x, y);
		end;

	select_it (x, y : INTEGER) is
		do
			if source_line_contains(x, y) then
				set_source_selected;
			else
				check one_contains: destination_line_contains(x, y) end;
					-- Our (inherited) precondition guarantees this.
				set_destination_selected;
			end; -- if
		end;


	set_source_selected is
		do
			selection_state := source_selected_state;
		end;


	set_destination_selected is
		do
			selection_state := destination_selected_state;
		end;

	deselect is
		do
			selection_state := nothing_selected_state;
		end

	is_selected : BOOLEAN is
		do
			result := selection_state /= nothing_selected_state;
		end;

	source_is_selected : BOOLEAN is
		do
			Result := selection_state = source_selected_state
					  or else (is_selected and then must_be_straight_line);
		end;

	destination_is_selected : BOOLEAN is
		do
			Result := selection_state = destination_selected_state
					  or else (is_selected and then must_be_straight_line);
		end;


feature { CONNECTION }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("manhattan-span");
			writer.write_integer(writer.get_span_endpoint_id(source));
			writer.write_integer(writer.get_span_endpoint_id(destination));
			if source_side_vertical then
				writer.write_token("true");
					-- Sure, I could use source_side_vertical.out, but
					-- relying on BOOLEAN to match the strings I choose
					-- feels wrong.
			else
				writer.write_token("false");
			end
			writer.right_paren;
			writer.new_line;
		end

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			src_str, dest_str, vert_str : STRING;
			a_source, a_destination : SPAN_ENDPOINT;
		do
			if args.count /= 3 then
				reader.error("Incorrect number of arguments for manhattan-span");
			end;
			src_str ?= args @ 1;
			dest_str ?= args @ 2;
			vert_str ?= args @ 3;
			if src_str = Void or else dest_str = Void
			   or else vert_str = Void
		    then
				reader.error("Error in arguments arguments to manhattan-span");
			end
			a_source ?= reader.get_span_endpoint(src_str);
			a_destination ?= reader.get_span_endpoint(dest_str);
			if vert_str.is_equal("true") then
				source_side_vertical := True
			elseif vert_str.is_equal("false") then
				source_side_vertical := False
			else
				reader.error("Error in arguments arguments to manhattan-span");
			end
			set_source(a_source);
			set_destination(a_destination);
			must_be_straight_line := False;

			reader.add_span(Current);
		end;

feature	{ MANHATTAN_SPAN }	--	Protected

	source_line : CANVAS_LINE;
	destination_line : CANVAS_LINE;

	selection_state : INTEGER;	-- An enum giving the state of our selection
		source_selected_state, 
		destination_selected_state, 
		nothing_selected_state 						: INTEGER is unique ;

	set_positions is
		local
			src_p, dest_p : POINT;
		do
			src_p := source.pos_after_decoration;
			dest_p := destination.pos_after_decoration;
			if source_side_vertical then
				midpoint_x := src_p.x;
				midpoint_y := dest_p.y;
			else
				midpoint_y := src_p.y;
				midpoint_x := dest_p.x;
			end;
			source_line.set_coords(src_p.x,
								   src_p.y,
								   midpoint_x, midpoint_y);
			destination_line.set_coords(midpoint_x, midpoint_y, 
										dest_p.x, dest_p.y);
		end;

	source_must_be_vertical : BOOLEAN is
			-- Do the constraints require a vertical source_line?
		do
			if source.constraint /= Void 
				and then source.constraint.requires_vertical_spans
			then
				Result := True
			elseif destination.constraint /= Void
				and then destination.constraint.requires_horizontal_spans
			then
				Result := True;
			else
				Result := False;
			end
		end; -- do


	source_must_be_horizontal: BOOLEAN is
			-- Do the constraints require a horizontal source_line?
		do
			if source.constraint /= Void 
				and then source.constraint.requires_horizontal_spans
			then
				Result := True
			elseif destination.constraint /= Void
				and then destination.constraint.requires_vertical_spans
			then
				Result := True;
			else
				Result := False;
			end
		end; -- do

	source_line_contains (x, y : INTEGER) : BOOLEAN is
			-- Is the point x,y within selection_slop of the source
			-- line?
		local
			min_c, max_c : INTEGER;
		do
			if source_side_vertical then
				min_c := source.y.min(destination.y) - selection_slop;
				max_c := source.y.max(destination.y) + selection_slop;
				Result := y >= min_c and then y <= max_c 
						  and then (x - source.x).abs <= selection_slop;
			else	-- source side is horizontal
				min_c := source.x.min(destination.x) - selection_slop;
				max_c := source.x.max(destination.x) + selection_slop;
				Result := x >= min_c and then x <= max_c
						  and then (y - source.y).abs <= selection_slop;
			end; -- if
		end;


	destination_line_contains (x, y : INTEGER) : BOOLEAN is
			-- Is the point x,y within selection_slop of the destination
			-- line?
		local
			min_c, max_c : INTEGER;
		do
			if not source_side_vertical then
				min_c := source.y.min(destination.y) - selection_slop;
				max_c := source.y.max(destination.y) + selection_slop;
				Result := y >= min_c and then y <= max_c 
						  and then (x - destination.x).abs <= selection_slop;
			else	-- destination side is horizontal
				min_c := source.x.min(destination.x) - selection_slop;
				max_c := source.x.max(destination.x) + selection_slop;
				Result := x >= min_c and then x <= max_c
						  and then (y - destination.y).abs <= selection_slop;
			end; -- if
		end;


end -- class MANHATTAN_SPAN
