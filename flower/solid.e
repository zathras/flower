deferred class SOLID

inherit

	DRAWABLE
		redefine
			contains, bounding_box, single_select, attempt_multiple_select, 
			deselect, move_selected, set_diagram
		select
			set_diagram
		end;
	DRAWABLE
		rename
			set_diagram as drawable_set_diagram
		end;


feature		-- Initialize/Release

	init_solid(a_left : INTEGER; a_top: INTEGER;
			   a_width : INTEGER; a_height : INTEGER;
			   a_diagram : DIAGRAM) is
		do
			!!bounding_box.make(a_left, a_top, a_width, a_height);
			!!selection_rects.make(1, 4);
			!!connections.make(0);
			init_drawable(a_diagram);
			if a_diagram /= Void then
				solid_diagram_init;
			end

		end;



feature			-- Querying

	contains (x : INTEGER; y : INTEGER) : BOOLEAN is
		do
			Result := bounding_box.contains(x, y);
		end;

	left : INTEGER is
		do
			result := bounding_box.left;
		end;

	top : INTEGER is
		do
			result := bounding_box.top;
		end;

	right : INTEGER is
		do
			result := bounding_box.right;
		end;

	bottom : INTEGER is
		do
			result := bounding_box.bottom;
		end;

	height : INTEGER is
		do
			result := bounding_box.height;
		end;

	width : INTEGER is
		do
			result := bounding_box.width;
		end;

	endpoint_intersection_with_line (line : LINE_SEGMENT) : SPAN_ENDPOINT is
			-- Find the point where our bounding box intersects the
			-- LINE_SEGMENT line.  Give Void if it doesn't.  The SPAN_ENDPOINT
			-- returned will be constrained to the side of the solid
			-- where the intersection occurred.
		local
			tmp : LINE_SEGMENT;
			p : POINT;
			constraint : ENDPOINT_CONSTRAINT;
		do
								-- Try left side
			!!tmp.make(left, top, left, bottom);
			p := line.intersection_point(tmp);
			if p /= Void then
				!ENDPOINT_SOLID_LEFT_CONSTRAINT!constraint.make(Current);
			else
								-- Try the top side
				tmp.set_coordinates(left, top, right, top);
				p := line.intersection_point(tmp);
				if p /= Void then
					!ENDPOINT_SOLID_TOP_CONSTRAINT!constraint.make(Current);
					!!Result.make_constrained(p.x, p.y, constraint);
				else
								-- Try the right side
					tmp.set_coordinates(right, top, right, bottom);
					p := line.intersection_point(tmp);

					if p /= Void then
						!ENDPOINT_SOLID_RIGHT_CONSTRAINT!constraint
							.make(Current);
						!!Result.make_constrained(p.x, p.y, constraint);
					else
								-- Try the bottom side
						tmp.set_coordinates(left, bottom, right, bottom);
						p := line.intersection_point(tmp);
						if p /= Void then
							!ENDPOINT_SOLID_BOTTOM_CONSTRAINT!constraint
								.make(Current);
						end;
					end
				end
			end
			if p /= Void then
				!!Result.make_constrained(p.x, p.y, constraint);
				check result_ok: Result.x = p.x and then Result.y = p.y end;
			end;
		end;

feature			-- Modification

	deselect is
		do
			selected := False;
			move_selection_rects;
		end;

	attempt_multiple_select is
			-- solids can by default be multiple-selected
		do
			selected := True;
			move_selection_rects;
		end;

	single_select (x, y : INTEGER) is
		do
			selected := True;
			move_selection_rects;
		end;

	move_selected (delta_x : INTEGER; delta_y : INTEGER) is
		do
			bounding_box.set_left(bounding_box.left + delta_x);
			bounding_box.set_top(bounding_box.top + delta_y);
			move_selection_rects;
		end;

feature			-- Attributes

	bounding_box : BOUNDING_BOX;

	connections : ARRAYED_LIST [CONNECTION];
		-- All of the connections attached to this solid.

feature			-- Services

	make_best_manhattan_span(x : INTEGER; y : INTEGER) : MANHATTAN_SPAN is
			-- Calculate the most reasonable span from the solid to x,y
		require
			non_contained: not bounding_box.contains(x, y)
		local
			line : LINE_SEGMENT;
			source : SPAN_ENDPOINT;
			destination : SPAN_ENDPOINT;
			source_side_vertical : BOOLEAN;
		do
			!!line.make(bounding_box.midpoint_x, bounding_box.midpoint_y, x,y);
			source := endpoint_intersection_with_line(line);
			check source_found: source /= Void end;
			source_side_vertical := source.requires_vertical_spans;
			!!destination.make(x, y);
			!MANHATTAN_SPAN!Result.make(source, destination, 
									    diagram.canvas, 
									    source_side_vertical);
		end;



feature { CONNECTION }	-- Connection management

	add_connection (a_connection : CONNECTION) is
		do
			connections.extend(a_connection);
		end;

feature { DRAWABLE }	-- Protected

	set_diagram (d : DIAGRAM) is
		do
			drawable_set_diagram(d);
			solid_diagram_init;
		end;

	solid_diagram_init is
			-- Initializatino to be done on a solid once the diagram is set
		require
			diagram_set : diagram /= Void
	    local
			i : INTEGER;
			rect : CANVAS_RECT;
		do
			from
				i := selection_rects.lower
			until
				i > selection_rects.upper
			loop
				!!rect.make(diagram.canvas);
				rect.set_fill_color("black");
				selection_rects.put(rect, i);
				i := i + 1;
			end;
		end;


feature { SOLID }		-- Subclass services

	set_width (a_width : INTEGER) is
		do
			bounding_box.set_width(a_width);
		end;

	set_height (a_height : INTEGER) is
		do
			bounding_box.set_height(a_height);
		end;

	move_selection_rects is
		do
			if selected then
				(selection_rects @ 1)
					.set_coords(left - 3, top - 3, left + 2, top + 2);
				(selection_rects @ 2)
					.set_coords(right - 3, top - 3, right + 2, top + 2);
				(selection_rects @ 3)
					.set_coords(left - 3, bottom - 3, left + 2, bottom + 2);
				(selection_rects @ 4)
					.set_coords(right - 3, bottom - 3, right + 2, bottom + 2);
			else
				(selection_rects @ 1).set_coords(-10, -10, -10, -10);
				(selection_rects @ 2).set_coords(-10, -10, -10, -10);
				(selection_rects @ 3).set_coords(-10, -10, -10, -10);
				(selection_rects @ 4).set_coords(-10, -10, -10, -10);
			end;
		end;

feature { NONE }	-- Implementation


	selection_rects : ARRAY [ CANVAS_RECT ];

end -- class SOLID
