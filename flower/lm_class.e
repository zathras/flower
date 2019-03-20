class LM_CLASS 
	-- Represents a class.  Classes are methodology-neutral.

inherit

	LOGICAL_MODEL_ITEM
		undefine
			is_equal
		redefine
			can_be_edited, 
			launch_editor,
			make_for_reader,
			write_for_writer
		end;
	COMPARABLE			-- So we can sort them by name
		redefine
			infix "<", is_equal
		end;

creation

	make,
	make_for_reader

feature		-- Initialize/Release

	make (a_logical_model : LOGICAL_MODEL; a_name : STRING) is
		do
			init_item(a_logical_model);
			name := clone(a_name);
			!!methods.make(0);
			!!variables.make(0);
		end;


feature		-- Comparison

	infix "<" (other : like Current) : BOOLEAN is
		do
			Result := name < other.name
		end;

	is_equal (other : like current) : boolean is
		do
			Result := name.is_equal(other.name)
		end;

feature		-- Modification

	set_name (a_name : STRING) is
		do
			name := clone(a_name);
			notify_change;
		end;

	append_variable (variable : LM_VARIABLE) is
		do
			variables.extend(variable);
			notify_change;
		end;

	replace_variable (variable : LM_VARIABLE; index : INTEGER) is
		do
			variables.put_i_th(variable, index);
			notify_change;
		end;

	remove_variable (index : INTEGER) is
		do
			variables.go_i_th(index);
			variables.remove;
			notify_change;
		end;

	append_method (method : LM_METHOD) is
		do
			methods.extend(method);
			notify_change;
		end;

	replace_method (method : LM_METHOD ; index : INTEGER) is
		do
			methods.put_i_th(method, index);
			notify_change;
		end;

	remove_method (index : INTEGER) is
		do
			methods.go_i_th(index);
			methods.remove;
			notify_change;
		end;

feature		-- Editing

	can_be_edited : BOOLEAN is True;

	launch_editor is
		do
			class_editor.launch(Current);
		end;


feature		-- Atrributes

	name : STRING;

	methods : ARRAYED_LIST [ LM_METHOD ];
	variables : ARRAYED_LIST [ LM_VARIABLE ];


feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			i : INTEGER;
		do
			writer.left_paren;
			writer.write_token("lm-class");
			writer.write_integer(writer.get_lm_id(Current));
			writer.write_string(name);
			from i := 1 until i > methods.count loop
				(methods @ i).write_for_writer(writer);
				i := i + 1;
			end
			from i := 1 until i > variables.count loop
				(variables @ i).write_for_writer(writer);
				i := i + 1;
			end
			writer.right_paren;
			writer.new_line;
		end;


feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			method : LM_METHOD;
			variable : LM_VARIABLE;
			id_str : STRING;
		do
			if args.count < 2 then
				reader.error("Not enough arguments for class");
			end;
			id_str ?= args @ 1;
			name ?= args @ 2;
			if name = Void then
				reader.error("String expected for class name")
			end
			init_item(reader.project.logical_model);
			!!methods.make(0);
			!!variables.make(0);
			from i := 3 until i > args.count loop
				method ?= args @ i;
				variable ?= args @ i;
				if method /= Void then
					methods.extend(method);
				elseif variable /= Void then
					variables.extend(variable);
				else
					reader.error("Method or variable expected for class");
				end
				i := i + 1;
			end -- loop
			reader.check_id_str(id_str);
			force_i_th_item(reader, Current, id_str.to_integer);
		end;

feature	{ LM_CLASS } 	-- Implementation

	class_editor : EDIT_CLASS_DIALOG is
		once
			!!Result.make(logical_model.app.tk_app);
		end;

end -- class LM_CLASS
