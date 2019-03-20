class CLASS_BOX 
	-- Represents a drawing of a Rumbaugh class on a diagram.

inherit

	SOLID
		redefine
			move_selected,
			logical_model_item,
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
			logical_model_item,
			make_for_reader,
			init_from_reader,
			write_for_writer
		end;

	OBSERVER
		redefine
			notify_change,
			notify_release
		end;

creation

	make,
	make_for_reader


feature		-- Initialize/Release

	make(a_left : INTEGER; a_top : INTEGER; a_class : LM_CLASS; 
		 a_diagram : DIAGRAM) is
		local
			a_width : INTEGER;
			a_height : INTEGER;
		do
			!!it_member_names.make(0);
			the_class := a_class;
			init_solid (a_left, a_top, 10, 35, a_diagram);
			populate_diagram;
			notify_change; -- Changes height and width, and places items
			the_class.add_observer(Current);
		end;


feature		-- Querying

	logical_model_item : LOGICAL_MODEL_ITEM is
		do
			Result := the_class;
		end;


feature		-- Modification

	move_selected (delta_x : INTEGER; delta_y : INTEGER) is
		do
			solid_move_selected(delta_x, delta_y);
			place_items;
		end;

feature		-- Attributes

	the_class : LM_CLASS;

	subclass_triangle : INHERITANCE_TRIANGLE;
		-- If subclasses are indicated for this class on this diagram, this
		-- triange is used to represent all of the subclassing relationships.

	name : STRING is
		do
			Result := the_class.name;
		end;


feature { OBSERVER }	-- Notification

	notify_change is
		local
			i : INTEGER;
		do
			update_class_box_placement;
			from i := 1 until i > connections.count loop
				(connections @ i).note_moved_solids;
				i := i + 1;
			end -- loop
		end;

	notify_release is
		do
			-- @@ Do this
		end;


feature { INHERITANCE_TRIANGLE }	-- Inheritance triangle connection

	set_subclass_triangle (t : INHERITANCE_TRIANGLE) is
		do
			subclass_triangle := t
		end;



feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("class-box");
			writer.write_integer(writer.get_drawable_id(Current));
			writer.write_integer(writer.get_lm_id(the_class));
			writer.write_integer(left);
			writer.write_integer(top);
			writer.right_paren;
			writer.new_line;
		end;

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str, lm_id_str : STRING;
			left_str, top_str : STRING;
		do
			if args.count /= 4 then
				reader.error("Incorrect number of arguments for class-box");
			end;
			id_str ?= args @ 1;
			lm_id_str ?= args @ 2;
			left_str ?= args @ 3;
			top_str ?= args @ 4;
			if lm_id_str = Void
			   or else left_str = Void or else top_str = Void
			   or else (not left_str.is_integer)
			   or else (not top_str.is_integer)
		    then
				reader.error("Error in arguments arguments to class-box");
			end
			!!it_member_names.make(0);
			the_class ?= reader.get_lm_item(lm_id_str);
			if the_class = Void then
				reader.error("Error in arguments arguments to class-box");
			end
			init_solid(left_str.to_integer, top_str.to_integer, 10, 35, Void);
				-- The diagram (the last arg) gets set in init_from_reader.

			reader.add_diagram_drawable(id_str, Current);
		end;

feature { DIAGRAM }		-- Streaming support

	init_from_reader (a_diagram : DIAGRAM) is
		local
			i : INTEGER;
		do
			set_diagram(a_diagram);
			populate_diagram;
			update_class_box_placement;
				-- Chganges height and width, and places items
			the_class.add_observer(Current);
		end;



feature { DRAWABLE }	-- Implementation


	populate_diagram is		-- Add necessary figures to the canvas
		do
			!!it_main_box.make(diagram.canvas);
			it_main_box.set_outline_width(2);

			!!it_class_name.make(diagram.canvas);

			!!it_seperator_1.make(diagram.canvas);
			it_seperator_1.set_width(2);

			!!it_seperator_2.make(diagram.canvas);
			it_seperator_2.set_width(2);
		end;

	update_class_box_placement is
		local
			a_width : INTEGER;
			a_height : INTEGER;
		do
			a_width := widest_string_width;
			set_width(a_width + 14);
			a_height := class_name_height + method_names_height
						      			  + variable_names_height;
			if the_class.methods.count = 0 then
			    set_height(a_height + 24);
			else
			    set_height(a_height + 22);
			end
			place_items;
		end;

	place_items is
		    -- Put the needed attributes into the Tk items
		    -- (i.e. fill the text items with their strings, and position
		    -- everything).
		local
			y : INTEGER;
			i, member : INTEGER;
			txt : CANVAS_TEXT;
		do
			member := 1;
			it_class_name.set_text(name);

			it_main_box.set_coords(left, top, right, bottom);
			it_class_name.set_coords(left + 8, top + 6);
			y := top + 9 + class_name_height;
			it_seperator_1.set_coords(left, y, right, y);
			y := y + 5;
			from i := 1 until i > the_class.variables.count loop
				txt := get_it_member_name(member);
				txt.set_text((the_class.variables @ i).name);
				txt.set_coords(left + 8, y);
				y := y + tk_app.character_height;
				i := i + 1;
				member := member + 1;
			end -- loop

			y := y + 2;
			it_seperator_2.set_coords(left, y, right, y);
			y := y + 4;
			from i := 1 until i > the_class.methods.count loop
				txt := get_it_member_name(member);
				txt.set_text((the_class.methods @ i).name);
				txt.set_coords(left + 8, y);
				y := y + tk_app.character_height;
				i := i + 1;
				member := member + 1;
			end -- loop

				-- Now erase any leftover member name text items
			from until member > it_member_names.count loop
				txt := get_it_member_name(member);
				txt.set_text("");
				txt.set_coords(-10, -10);
				member := member + 1;
			end -- loop

			move_selection_rects;
		end;

	widest_string_width : INTEGER is
			-- Give the width of the widest string in the class box.
		local
			i : INTEGER;
			s : STRING;
		do
			Result := diagram.tk_app.width_of(the_class.name);
			from i := 1 until i > the_class.variables.count loop
				s := (the_class.variables @ i).name;
				Result := Result.max(diagram.tk_app.width_of(s));
				i := i + 1;
			end -- loop
			from i := 1 until i > the_class.methods.count loop
				s := (the_class.methods @ i).name;
				Result := Result.max(diagram.tk_app.width_of(s));
				i := i + 1;
			end -- loop
		end;

	method_names_height : INTEGER is
		-- Give the height of the method names strings
		do
			Result := tk_app.character_height * the_class.methods.count;
		end;

	variable_names_height : INTEGER is
		-- Give the height of the variable names strings
		do
			Result := tk_app.character_height * the_class.variables.count;
		end;

	class_name_height : INTEGER is
		-- Give the height of the class name string
		do
			Result := tk_app.character_height;
		end;

	get_it_member_name (i : INTEGER) : CANVAS_TEXT is
		-- Get it_member_name number i, even if it means creating it.
		local
			new_text : CANVAS_TEXT;
		do
			from until i <= it_member_names.count loop
				!!new_text.make(diagram.canvas);
				it_member_names.extend(new_text);
			end
			Result := it_member_names @ i;
		end;

feature { NONE }		-- Tk items

	it_main_box : CANVAS_RECT;
	it_class_name : CANVAS_TEXT;
	it_seperator_1 : CANVAS_LINE;	-- Between class name and variables
	it_seperator_2 : CANVAS_LINE;	-- Between variables and methods

	it_member_names : ARRAYED_LIST [ CANVAS_TEXT ];

end -- class CLASS_BOX
