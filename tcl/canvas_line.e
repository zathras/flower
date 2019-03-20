class CANVAS_LINE
	-- Represents a line on a canvas.  This can be a simple line
	-- segment (if set_coords is used), or a series of line segments
	-- (if set_coord_list is used).

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
			command.append(" create line");
			command.int_arg(-2);
			command.int_arg(-2);
			command.int_arg(-1);
			command.int_arg(-1);
			an_id := a_canvas.app.eval(command).to_integer;
			canvas_item_init(a_canvas, an_id);
		end;

feature		-- Element Change

	set_coords (x1 : INTEGER; y1 : INTEGER; 
			    x2 : INTEGER; y2 : INTEGER) is
			-- Set the coordinates of a line segment.  cf. set_coord_list
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" coords");
			command.int_arg(id);
			command.int_arg(x1);
			command.int_arg(y1);
			command.int_arg(x2);
			command.int_arg(y2);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;

	set_coord_list (coords : ARRAYED_LIST [ POINT ]) is
			-- Sets the coordinates of a series of line segments that
			-- are represented as one line.
		require
			at_least_two_coordinates : coords.count >= 2;
		local
			i : INTEGER;
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" coords");
			command.int_arg(id);
			from i := 1 until i > coords.count loop
				command.int_arg((coords  @ i).x);
				command.int_arg((coords  @ i).y);
				i := i + 1;
			end
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;


	set_width (w : INTEGER) is
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

	set_color (color : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(canvas.name);
			command.append(" itemconfigure");
			command.int_arg(id);
			command.append(" -fill");
			command.string_arg(color);
			res := app.eval(command);
			check 
				result_ok : res.is_equal("");
			end;
		end;


end -- class CANVAS_LINE_SEGMENT
