class CANVAS_RECT 
	-- Represents a rectangle item on a canvas.

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
			command.append(" create rect");
			command.int_arg(-2);
			command.int_arg(-2);
			command.int_arg(-1);
			command.int_arg(-1);
			an_id := a_canvas.app.eval(command).to_integer;
			canvas_item_init(a_canvas, an_id);
		end;

feature		-- Element Change

	set_coords (left : INTEGER; top : INTEGER; 
			    right : INTEGER; bottom : INTEGER) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" coords");
			command.int_arg(id);
			command.int_arg(left);
			command.int_arg(top);
			command.int_arg(right);
			command.int_arg(bottom);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

	set_outline_width (w : INTEGER) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" itemconfigure");
			command.int_arg(id);
			command.append(" -width");
			command.int_arg(w);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

	set_outline_color (c : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" itemconfigure");
			command.int_arg(id);
			command.append(" -outline");
			command.string_arg(c);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

	set_fill_color (c : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" itemconfigure");
			command.int_arg(id);
			command.append(" -fill");
			command.string_arg(c);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

end -- class CANVAS_RECT
