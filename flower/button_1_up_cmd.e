
class BUTTON_1_UP_CMD inherit
	-- Forwards a button 1 up Tk event (in a canvas) to a controller.
	-- The command is named "button_release_1<canvas_name>".

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

	name : STRING is "diagram_mouse_1_up";

	app : FLOWER_MAIN;


feature { MOUSE_CMD } 	-- Implementation

	do_command(controller : CONTROLLER; x : INTEGER; y : INTEGER) is
		do
			controller.button_1_up(x, y);
		end;


end -- class BUTTON_1_UP_CMD
