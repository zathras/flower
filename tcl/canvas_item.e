class CANVAS_ITEM 
	-- Represents a graphical item on a Tk canvas.  CANVAS_ITEM represents
	-- a fairly thin layer over the builtin Tk canvas item routines -- canvas
	-- items don't remember their position, calculate bounding boxes, or hide
	-- themselves.  (Just like Tk canvas items, they are hidden my moving
	-- them off the canvas!)
	--
	-- Higher-level graphical objects are represented by the DRAWABLE
	-- hierarchy.  DRAWABLEs are constructed out of the different kinds of
	-- CANVAS_ITEM.
	--
	-- NOTE:  This hierarchy is currently implemented by sending strings
	--		  to the Tcl interpreter.  A faster implementation that talks
	--		  directly to the C library is almost certainly possible.




feature			-- Initialize/Release

	release is
			-- Delete this item from the canvas
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" delete");
			command.int_arg(id);
			res := canvas.app.eval(command);
			check
				result_ok : res.is_equal("")
			end;
		end;

feature { CANVAS_ITEM }		-- Protected

	canvas_item_init (a_canvas : TK_CANVAS; an_id : INTEGER) is
		do
			canvas := a_canvas;
			id := an_id;
		end;

	canvas : TK_CANVAS;

	id : INTEGER;		-- Within a canvas, Tk tracks them by integer id.

	app : TK_APPLICATION is
		do
			Result := canvas.app
		end;

end -- class CANVAS_ITEM
