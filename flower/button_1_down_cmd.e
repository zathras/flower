class BUTTON_1_DOWN_CMD inherit
	-- Forwards a button 1 down Tk event (in a canvas) to a controller.

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

	name : STRING is "diagram_mouse_1_down";

	app : FLOWER_MAIN;


feature { MOUSE_CMD } 	-- Implementation

	do_command(controller : CONTROLLER; x : INTEGER; y : INTEGER) is
		do
			controller.button_1_down(x, y);
		end;


end -- class BUTTON_1_DOWN_CMD
