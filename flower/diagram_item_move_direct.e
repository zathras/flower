class DIAGRAM_ITEM_MOVE_DIRECT 
	-- Represents the act of moving a single diagram item across the
	-- canvas.  The item must support direct drag.  cf. DIAGRAM_ITEM_MOVE
	-- for a more general dragging command.


inherit

	DIAGRAM_DRAG
		redefine
			mouse_move, mouse_up
		end;

creation

	make

feature		-- Initialize/Release

	make (a_controller : CONTROLLER; a_start_x, a_start_y : INTEGER;
		  a_drawable : DRAWABLE) is
		require
			supports_direct_drag : a_drawable.supports_direct_drag
		do
			controller := a_controller;
			start_x := a_start_x;
			start_y := a_start_y;
			last_x := start_x;
			last_y := start_y;
			drawable := a_drawable;
		end;

feature		-- Actions

	mouse_move(x, y : INTEGER) is
		do
			drawable.move_selected(x - last_x, y - last_y);
			last_x := x;
			last_y := y;
			if not drawable.selected then
					-- Something went wrong, and the drawable is no longer
					-- selected.  This might happen if the drawable was
					-- forced to change under the movement such that the
					-- part that was selected no longer exists.
				drawable.finalize_placement;
				controller.cancel_current_drag;
				controller.tk_app.bell;
			end
		end;

	mouse_up (x, y : INTEGER) is
		do
			mouse_move(x, y);
			drawable.finalize_placement;
			controller.cancel_current_drag;
		end;

feature { NONE }			-- Implementation

	controller : CONTROLLER;
	start_x, start_y : INTEGER;
	last_x, last_y : INTEGER;
	drawable : DRAWABLE;

	diagram : DIAGRAM is
		do
			Result := controller.diagram
		end;

end -- class DIAGRAM_ITEM_MOVE_DIRECT
