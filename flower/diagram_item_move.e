class DIAGRAM_ITEM_MOVE 
	-- represents the act of moving one or more diagram items across
	-- the canvas.  On mouse up, the command ends and the items are
	-- placed.

inherit

	DIAGRAM_DRAG
		redefine
			mouse_move, mouse_up
		end;

creation

	make

feature		-- Initialize/Release

	make(a_controller : CONTROLLER; a_start_x : INTEGER; a_start_y : INTEGER) is
		local
			i : integer;
		do
			controller := a_controller;
			start_x := a_start_x;
			start_y := a_start_y;
			!!box.make(start_x, start_y, 0, 0);
			from i := 1 until i > diagram.selected.count loop
				box.expand_to_include_box((diagram.selected @ i).bounding_box);
				i := i + 1;
			end;
			box_start_left := box.left;
			box_start_top := box.top;
			diagram.position_drag_rect(box);
			diagram.set_cursor("fleur");
		end;

feature		-- Actions

	mouse_move(x : INTEGER; y : INTEGER) is
		do
			move_box(x, y);
		end;

	mouse_up(x : INTEGER; y : INTEGER) is
		local
			delta_x : INTEGER;
			delta_y : INTEGER;
		do
			move_box(x, y);
			delta_x := box.left - box_start_left;
			delta_y := box.top - box_start_top;
			move_drawables(delta_x, delta_y);
			move_connections(delta_x, delta_y);

			box.set_left(-5);
			box.set_top(-5);
			box.set_height(0);
			box.set_width(0);
			diagram.position_drag_rect(box);
			diagram.set_cursor("");
			controller.cancel_current_drag;
		end;


feature { NONE }		-- Implementation

	controller : CONTROLLER;
	start_x : INTEGER;
	start_y : INTEGER;
	box_start_left : INTEGER;
	box_start_top : INTEGER;

	box : BOUNDING_BOX;		-- The box that contains the selection area

	diagram : DIAGRAM is
		do
			Result := controller.diagram;
		end;

	move_box(x : INTEGER; y : INTEGER) is
		do
			box.set_left(box_start_left + (x - start_x));
			box.set_top(box_start_top + (y - start_y));
			diagram.position_drag_rect(box);
		end;


	move_drawables(delta_x, delta_y : INTEGER) is
			-- Move all of the selected drawables on the diagram
		local
			i : INTEGER;
		do
			from i := 1 until i > diagram.selected.count loop
				(diagram.selected @ i).move_selected(delta_x, delta_y);
				i := i + 1;
			end
		end;

	move_connections (delta_x, delta_y : INTEGER) is
			-- Move all of the connections in which selected drawables
			-- participate.
		local
			i : INTEGER;
			connections : ARRAYED_LIST [CONNECTION];
		do
			connections := all_selected_connections;
			from i := 1 until i > connections.count loop
				(connections @ i).move(delta_x, delta_y);
				i := i + 1;
			end;
		end;

	all_selected_connections : ARRAYED_LIST [CONNECTION] is
			-- The list of all of the connections in which selected
			-- drawables participate.
		local
			i, j : INTEGER;
			d : SOLID;
		do
			!!Result.make(0);
			from i := 1 until i > diagram.selected.count loop
				d ?= diagram.selected @ i;	-- Only solids have connections
				if d /= Void then
					from j := 1 until j > d.connections.count loop
						if not Result.has (d.connections @ j) then
							Result.extend(d.connections @ j)
						end
						j := j + 1;
					end  -- loop
				end -- if
				i := i + 1;
			end -- loop
		end;

end -- class DIAGRAM_ITEM_MOVE
