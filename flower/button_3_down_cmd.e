class BUTTON_3_DOWN_CMD 
	-- Forwards a button 3 down Tk event (in a canvas) to a controller.

inherit
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

	name : STRING is "diagram_mouse_3_down";

	app : FLOWER_MAIN;


feature { MOUSE_CMD } 	-- Implementation

	do_command(controller : CONTROLLER; x : INTEGER; y : INTEGER) is
		do
			controller.button_3_down(x, y);
		end;


end -- class BUTTON_3_DOWN_CMD
