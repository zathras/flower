class MOUSE_MOVE_CMD inherit
	-- Forwards a mouse motion Tk event (in a canvas) to a controller.
	-- The command is named "mouse_move<canvas_name>".

	MOUSE_CMD
		redefine
			name, do_command, app
		end;

	EXCEPTIONS

creation

	make

feature		-- Initialilze/Release

	make (an_app : FLOWER_MAIN) is
		local
		do
			app := an_app;
		end;


feature		-- Attributes

	name : STRING is "diagram_mouse_motion";

	app : FLOWER_MAIN;


feature { MOUSE_CMD } 	-- Implementation

	do_command(controller : CONTROLLER; x : INTEGER; y : INTEGER) is
		do
			controller.mouse_move(x, y);
		end;


end -- class MOUSE_MOVE_CMD
