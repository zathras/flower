class DIAGRAM_ITEM_MOVE_START 
	-- Represents the beginning of moving diagram items.  This is the part
	-- after the mouse down, bug before the mouse has moved beyond the
	-- hysteresis.

inherit

	DIAGRAM_DRAG
		redefine
			mouse_move, mouse_up
		end;

creation

	make


feature		-- Initialize/Release

	make(a_controller : CONTROLLER; x : INTEGER; y : INTEGER) is
		do
			controller := a_controller;
			start_x := x;
			start_y := y;
		end;


feature			-- Callaback

	mouse_move(x : INTEGER; y : INTEGER) is
		do
			if passed_hysteresis(x, y) then
				controller.start_item_drag(start_x, start_y, x, y);
			end;
		end;

	mouse_up(x : INTEGER; y : INTEGER) is
		do
			if passed_hysteresis(x, y) then
				controller.start_item_drag(start_x, start_y, x, y);
				controller.current_drag.mouse_up(x, y);
			else
				controller.cancel_current_drag;
			end;
		end;

feature { NONE }	-- Implementation

	controller : CONTROLLER;
	start_x : INTEGER;
	start_y : INTEGER;

	hysteresis : INTEGER is 5;	-- Amount they must move mouse to start drag

	passed_hysteresis(x : INTEGER; y : INTEGER) : BOOLEAN is
		do
			Result := ((x - start_x).abs >= hysteresis)
					  or else ((y - start_y).abs >= hysteresis);
		end;


end -- class DIAGRAM_ITEM_MOVE_START
