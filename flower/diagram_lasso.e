class DIAGRAM_LASSO
	-- represents an ongoing lasso in a diagram (for multiple select)

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
			diagram.position_drag_rect(box);
			diagram.set_cursor("sizing");
		end;

feature		-- Actions

	mouse_move(x : INTEGER; y : INTEGER) is
		do
			move_box(x, y);
		end;

	mouse_up(x : INTEGER; y : INTEGER) is
		local
			i : INTEGER;
		do
			move_box(x, y);

			from i := 1 until i > diagram.drawables.count loop
				if (diagram.drawables @ i).bounding_box.is_within(box) then
					diagram.drawable_multiple_selection(diagram.drawables @ i);
				end;
				i := i + 1;
			end;

			box.set_left(-5);
			box.set_top(-5);
			box.set_height(0);
			box.set_width(0);
			diagram.position_drag_rect(box);
			diagram.set_cursor("");
			controller.cancel_current_drag;
		end;


feature { NONE }		-- Implementaition

	controller : CONTROLLER;
	start_x : INTEGER;
	start_y : INTEGER;

	box : BOUNDING_BOX;		-- The box that contains the selection area

	diagram : DIAGRAM is
		do
			Result := controller.diagram;
		end;

	move_box(x : INTEGER; y : INTEGER) is
		do
			box.set_to_point(start_x, start_y);
			box.expand_to_include(x, y);
			diagram.position_drag_rect(box);
		end;



end -- class DIAGRAM_LASSO
