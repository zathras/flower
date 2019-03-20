class CANVAS_TEXT 
	-- Represents a text item on a canvas.

inherit

	CANVAS_ITEM

creation

	make

feature		-- Initialize / Release

	make (a_canvas : TK_CANVAS) is
		local
			an_id : INTEGER;
			command : TCL_COMMAND_STRING;
		do
			!!command.make(a_canvas.name);
			command.append(" create text");
			command.int_arg(-1000);
			command.int_arg(-1000);
			command.append(" -anchor nw");
			an_id := a_canvas.app.eval(command).to_integer;
			canvas_item_init(a_canvas, an_id);
		end;

	set_coords (left : INTEGER; top : INTEGER) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" coords");
			command.int_arg(id);
			command.int_arg(left);
			command.int_arg(top);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

	set_text (s : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" itemconfigure");
			command.int_arg(id);
			command.append(" -text {");
			command.append(s);		-- We assume it doesn't contain { or }
			command.append("}");
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

feature		-- Element Change

end -- class CANVAS_TEXT
