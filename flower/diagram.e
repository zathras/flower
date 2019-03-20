deferred class DIAGRAM 
	-- Represents a drawing populated by objects (DRAWABLEs).
	-- The drawing is done onto a Tk canvas.


inherit

	PROJECT_STREAMABLE
		redefine
			make_for_reader,
			write_for_writer
		end

feature				-- Initialize/Release

	make (an_id : INTEGER; a_dialog_name, a_title : STRING; 
	      an_app : FLOWER_MAIN) is
		local
			canvas_name : STRING;
		do
			id := an_id;
			app := an_app;
			title := clone(a_title);
			dialog_name := clone(a_dialog_name);
			canvas_name := clone(a_dialog_name);
            canvas_name.append(".canvas");
			hint_label_name := clone(a_dialog_name);
			hint_label_name.append(".hint");
			!!canvas.make(tk_app, canvas_name);
			!!drawables.make(0);
			!!selected.make(0);
			!!controller.make(Current);
			!!drag_rect.make(canvas);
			drag_rect.set_outline_color("red");
		end;

	release is
			-- Destroy the widget tree prior to destruction of the
			-- DIALOG
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make("destroy ");
			command.append(dialog_name);
			res := tk_app.eval(command);
			check
				result_ok : res.is_equal("");
			end;
		end;


feature				-- Accessing

	id : INTEGER;			-- Unique id by which Tcl knows us

	dialog_name : STRING;	-- Name of the Tk dialog that holds this diagram

	title : STRING;			-- User's title for the dialog

	canvas : TK_CANVAS;		 -- The canvas in that dialog

	controller : CONTROLLER;	-- The controller takes our input events.

	app : FLOWER_MAIN;

	tk_app : TK_APPLICATION is
		do
			Result := app.tk_app;
		end;

feature 		-- Operations

	add_drawable (a_drawable : DRAWABLE) is
		do
			drawables.extend(a_drawable);
		end;

	show_hint (s : STRING) is
		local
			command : TCL_COMMAND_STRING;
			res : STRING;
		do
			!!command.make(hint_label_name);
			command.append(" config -text {");
			command.append(s);
			command.append("}");
			res := tk_app.eval(command);
			check
				result_ok : res.is_equal("");
			end;
		end;

	set_cursor (name : STRING) is
		local
			command : TCL_COMMAND_STRING;
            res : STRING;
        do
            !!command.make(canvas.name);
			command.append(" config -cursor");
			command.string_arg(name);
			res := tk_app.eval(command);
            check
                result_ok : res.is_equal("");
            end;
        end;


feature		-- Item Control

	-- These features are used by the logical model to get the appropriate
	-- graphical representations for various constructs.

	is_mult_one_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		deferred
		end;

	is_mult_optional_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		deferred
		end;

	is_mult_many_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		deferred
		end;

	is_aggregation_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		deferred
		end;

	make_mult_one_decoration : CONNECTION_DECORATION is
		deferred
		end;

	make_mult_optional_decoration : CONNECTION_DECORATION is
		deferred
		end;

	make_mult_many_decoration : CONNECTION_DECORATION is
		deferred
		end;

	make_aggregation_decoration : CONNECTION_DECORATION is
		deferred
		end;


feature		-- Attributes


	drawables : ARRAYED_LIST [ DRAWABLE ];	
			-- The drawables we're showing

feature	{ CONTROLLER, DIAGRAM_DRAG }	-- Access for controller


	deselect_all is
			-- deselect all of the drawables
		local
			i : INTEGER;
		do
			from i := 1 until i > selected.count loop
				(selected @ i).deselect;
				i := i + 1;
			end;
			selected.wipe_out;
		end;

	single_select_drawable (d : DRAWABLE; x, y : INTEGER) is
		do
			deselect_all;
			d.single_select(x, y);
			selected.extend(d);
		end;

	drawable_multiple_selection (d : DRAWABLE) is
			-- d was just indicated as part of a multiple-select operation.
			-- Its selectedness should be toggled.
		do
			if d.selected then
				d.deselect
				selected.prune (d);
			else
				if selected.count = 1 then
					-- The one item might be selected due to a single-select.
					-- If so, it might be one that doesn't support multiple
					-- select.
					(selected @ 1).attempt_multiple_select;
					if not (selected @ 1).selected then
						selected.wipe_out
					end -- if
				end;  -- if
				d.attempt_multiple_select;
				if d.selected then
					selected.extend(d)
				end -- if
			end;  -- if
		end;

	position_drag_rect(bb : BOUNDING_BOX) is
		-- Position the drag rectangle.  Hide it if bb is void.
		do
			if bb = Void then
				drag_rect.set_coords(-5, -5, -5, -5);
			else
				drag_rect.set_coords(bb.left, bb.top, bb.right, bb.bottom);
			end;
		end;


	selected : ARRAYED_LIST [ DRAWABLE ];	
			-- The drawables that are currently selected

	drag_rect : CANVAS_RECT;
			-- A rectangle used for dragging stuff around the screen.


feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			i : INTEGER;
			conn : CONNECTION;
		do
			writer.left_paren;
			writer.write_token(name_for_writer);
			writer.write_integer(writer.get_current_diagram_id);
			writer.write_string(title);
			writer.new_line;

			from i := 1 until i > drawables.count loop
				conn ?= drawables @ i;
				if conn = Void then
					(drawables @ i).write_for_writer(writer);
				end
				i := i + 1;
			end

			from i := 1 until i > drawables.count loop
				conn ?= drawables @ i;
				if conn /= Void then
					(drawables @ i).write_for_writer(writer);
				end
				i := i + 1;
			end

			writer.right_paren;
			writer.new_line;
		end;


feature { DIAGRAM }		-- Streaming Support


	name_for_writer : STRING is
		deferred
		end;

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str : STRING;
			drawable : DRAWABLE;
		do
			if args.count < 3 then
				reader.error("Not enough arguments for class");
			end;
			id_str ?= args @ 1;
			title ?= args @ 2;
			if title = Void then
				reader.error("String expected for diagram title")
			end
			!!drawables.make(0);
			from i := 3 until i > args.count loop
				drawable ?= args @ i;
				if drawable = Void then
					reader.error("Drawable expected for diagram");
				end
				i := i + 1;
				drawables.extend(drawable);
			end -- loop
			id := reader.project.next_diagram_id;
			reader.add_diagram(id_str, Current);
		end;

	init_from_reader (an_app : FLOWER_MAIN; a_dialog_name : STRING) is
			-- Do the initialization that was deferred in the reader.
			-- Initialization must be deferred until there is a canvas
			-- available.
		local
			i : INTEGER;
			canvas_name : STRING;
			connection : CONNECTION;
		do
			app := an_app;
			dialog_name := clone(a_dialog_name);
			canvas_name := clone(a_dialog_name);
            canvas_name.append(".canvas");
			hint_label_name := clone(a_dialog_name);
			hint_label_name.append(".hint");
			!!canvas.make(tk_app, canvas_name);
			!!selected.make(0);
			!!controller.make(Current);
			!!drag_rect.make(canvas);
			drag_rect.set_outline_color("red");
			from i := 1 until i > drawables.count loop
				connection ?= drawables @ i;
				if connection /= Void then
					connection.init_from_reader(Current);
				end
				i := i + 1;
			end -- loop
			from i := 1 until i > drawables.count loop
				connection ?= drawables @ i;
				if connection = Void then
					(drawables @ i).init_from_reader(Current);
				end
				i := i + 1;
			end -- loop
			from i := 1 until i > drawables.count loop
				connection ?= drawables @ i;
				if connection /= Void then
					connection.note_moved_solids;
				end
				i := i + 1;
			end -- loop
		end;

feature { NONE }		-- Private

	hint_label_name : STRING;


end -- class DIAGRAM
