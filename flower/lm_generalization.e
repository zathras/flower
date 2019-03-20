class LM_GENERALIZATION 
	-- Represents an association between two classes

inherit

	LM_CLASS_RELATIONSHIP
		redefine
			source_decoration_ok,
			make_source_decoration,
			destination_decoration_ok,
			make_destination_decoration,
			make_for_reader,
			write_for_writer
		end;
	OBSERVABLE;

creation

	make,
	make_for_reader

feature		-- Initialize/Release

	make (src, dest : LOGICAL_MODEL_ITEM) is
		-- src is subclass, dest is superclass
		do
			init_class_relationship(src, dest);
		end;


feature { CONNECTION }	-- Decoration Management


	source_decoration_ok (diagram : DIAGRAM;
						  decoration : CONNECTION_DECORATION) : BOOLEAN is
		do
			Result := decoration = Void
		end;

	make_source_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		do
			Result := Void;
		end;

	destination_decoration_ok (diagram : DIAGRAM;
							   decoration : CONNECTION_DECORATION) : BOOLEAN is
		do
			Result := decoration = Void
		end;

	make_destination_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		do
			Result := Void;
		end;


feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("lm-generalization");
			writer.write_integer(writer.get_lm_id(Current));
			writer.write_integer(writer.get_lm_id(source));
			writer.write_integer(writer.get_lm_id(destination));
			writer.right_paren;
			writer.new_line;
		end;


feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str, source_str, dest_str : STRING;
			src, dest : LOGICAL_MODEL_ITEM;
		do
			if args.count /= 3 then
				reader.error("Incorrect number of arguments for generalization");
			end;
			id_str ?= args @ 1;
			source_str ?= args @ 2;
			dest_str ?= args @ 3;
			if source_str = void or else dest_str = void
			   or else (not source_str.is_integer) 
			   or else (not dest_str.is_integer)
			   or else (source_str.to_integer < 1)
			   or else (dest_str.to_integer < 1)
		    then
				reader.error("Error in arguments to generalization");
			end
			if source_str.to_integer <= reader.project.logical_model.items.count
			then
				src ?= reader.project.logical_model.items @ source_str.to_integer
			end;
			if dest_str.to_integer <= reader.project.logical_model.items.count
			then
				dest ?= reader.project.logical_model.items @ dest_str.to_integer
			end;
			if src = Void or else dest = Void then
				reader.error("Error in arguments to generalization");
			end;
			init_class_relationship(src, dest);
			reader.check_id_str(id_str);
			force_i_th_item(reader, Current, id_str.to_integer);
		end;


end -- class LM_GENERALIZATION
