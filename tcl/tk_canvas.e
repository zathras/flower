class TK_CANVAS 
	-- Represents a Tk canvas widget.  See CANVAS_ITEM for some general
	-- comments on the canvas system.

creation

	make


feature		-- Initialize / Release

	make (an_app : TK_APPLICATION; a_name : STRING) is
		do
			app := an_app;
			name := clone(a_name);
		end;

feature		-- Attributes

	app : TK_APPLICATION;		-- The application that has this canvas

	name : STRING;				-- The name of the canvas

end -- class TK_CANVAS
