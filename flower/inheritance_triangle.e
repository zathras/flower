class INHERITANCE_TRIANGLE
	-- Represents a drawing of a Rumbaugh inheritance triangle on a diagram.

	-- @@ TO DO:  The behavior dragging connections that are attached
	-- @@		  to inheritance triangles isn't right...  They must not
	-- @@		  be allowed to change their constraints according to
	-- @@		  the bounding box.
inherit

	SOLID
		redefine
			move_selected,
			make_for_reader,
			init_from_reader,
			write_for_writer
		select
			move_selected
		end;

	SOLID
		rename
			move_selected as solid_move_selected
		redefine
			make_for_reader,
			init_from_reader,
			write_for_writer
		end;

creation

	make,
	make_for_reader


feature		-- Initialize/Release

	make(a_top_x, a_top_y : INTEGER; a_superclass : CLASS_BOX;
		 a_diagram : DIAGRAM) is
		do
			init_solid (a_top_x - triangle_half_width, a_top_y,
					    2 * triangle_half_width + 1, triangle_height,
					    a_diagram);
			superclass := a_superclass;
			superclass.set_subclass_triangle(Current);
			populate_diagram;
			place_items;
		end;


feature		-- Query

	top_x : INTEGER is
			-- x position of the top of the triangle
		do
			Result := left + triangle_half_width
		end;

feature		-- Modification

	move_selected (delta_x : INTEGER; delta_y : INTEGER) is
		do
			solid_move_selected(delta_x, delta_y);
			place_items;
		end;

	release is
		do
			superclass.set_subclass_triangle(Void);
			outline.release;
		end;


feature		-- Attributes

	superclass : CLASS_BOX;
		-- The class box we hang off of



feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("inheritance-triangle");
			writer.write_integer(writer.get_drawable_id(Current));
			writer.write_integer(writer.get_drawable_id(superclass));
			writer.write_integer(top_x);
			writer.write_integer(top);		-- y value of top point
			writer.right_paren;
			writer.new_line;
		end;

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str, super_id_str : STRING;
			top_x_str, top_y_str : STRING;
			a_top_x, a_top_y : INTEGER;
		do
			if args.count /= 4 then
				reader.error("Incorrect number of arguments for inheritance-triangle");
			end;
			id_str ?= args @ 1;
			super_id_str ?= args @ 2;
			top_x_str ?= args @ 3;
			top_y_str ?= args @ 4;
			if super_id_str = Void
			   or else top_x_str = Void or else top_y_str = Void
			   or else (not top_x_str.is_integer)
			   or else (not top_y_str.is_integer)
		    then
				reader.error("Error in arguments arguments to inheritance-triangle");
			end
			superclass ?= reader.get_diagram_drawable(super_id_str);
			if superclass = Void then
				reader.error("Error in arguments arguments to inheritance-triangle");
			end
			superclass.set_subclass_triangle(Current);
			a_top_x := top_x_str.to_integer;
			a_top_y := top_y_str.to_integer;
			init_solid (a_top_x - triangle_half_width, a_top_y,
					    2 * triangle_half_width + 1, triangle_height,
					    Void);
				-- The diagram (the last arg) gets set in init_from_reader.

			reader.add_diagram_drawable(id_str, Current);
		end;

feature { DIAGRAM }		-- Streaming support

	init_from_reader (a_diagram : DIAGRAM) is
		do
			set_diagram(a_diagram);
			populate_diagram;
			place_items;
		end;


feature { DRAWABLE }	-- Implementation


	triangle_half_width : INTEGER is 12;	-- delta-x from point to corner

	triangle_height : INTEGER is 10;

	populate_diagram is		-- Add necessary figures to the canvas
		do
			!!outline.make(diagram.canvas);
			outline.set_width(2);
		end;


	place_items is
		    -- Put the needed attributes into the Tk items
		    -- (i.e. fill the text items with their strings, and position
		    -- everything).
		local
			p0, p : POINT;
			coords : ARRAYED_LIST [ POINT ];
			y : INTEGER;
			i, member : INTEGER;
			txt : CANVAS_TEXT;
		do
			!!coords.make(4);
			!!p0.make(top_x, top);
			coords.extend(p0);
			!!p.make(left, bottom);
			coords.extend(p);
			!!p.make(right, bottom);
			coords.extend(p);
			coords.extend(p0);	-- Close the path
			outline.set_coord_list(coords);

			move_selection_rects;
		end;


feature { NONE }		-- Tk items

	outline : CANVAS_LINE;

end -- class INHERITANCE_TRIANGLE
