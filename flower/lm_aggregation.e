class LM_AGGREGATION
	-- Represents the source containing an aggregation of the destination

inherit

	LM_CLASS_RELATIONSHIP
		redefine
			can_be_edited,
			launch_editor,
			source_decoration_ok,
			make_source_decoration,
			destination_decoration_ok,
			make_destination_decoration,
			destination_attributes,
			set_destination_multiplicity,
			make_for_reader,
			write_for_writer
		end;
	OBSERVABLE

creation

	make,
	make_for_reader

feature		-- Initialize/Release

	make (src, dest : LOGICAL_MODEL_ITEM) is
		do
			init_class_relationship(src, dest);
			!!destination_attributes.make;
			destination_attributes.set_multiplicity(mult_one);
		end;


feature		-- Modification


	set_destination_multiplicity (m : MULTIPLICITY) is
		do
			destination_attributes.set_multiplicity(m);
			notify_change;
		end;

feature		-- Attributes

	destination_attributes :	LM_RELATIONSHIP_END_ATTRIBUTES;


feature		-- Editing

	can_be_edited : BOOLEAN is True;

	launch_editor is
		do
			editor.launch(Current);
		end;


feature { CONNECTION }	-- Decoration Management

	source_decoration_ok (diagram : DIAGRAM; 
						  decoration : CONNECTION_DECORATION) : BOOLEAN is
			-- Is this this right kind of decoration?
		do
			Result := diagram.is_aggregation_decoration(decoration);
		end;

	make_source_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		do
			Result := diagram.make_aggregation_decoration;
		end;

	destination_decoration_ok (diagram : DIAGRAM;
							   decoration : CONNECTION_DECORATION) : BOOLEAN is
			-- Is this this right kind of decoration?
		do
			Result := destination_attributes.multiplicity
						.is_decoration_for(diagram, decoration);
		end;

	make_destination_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		do
			Result := destination_attributes.multiplicity
									.make_decoration_for(diagram);
		end;

feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.left_paren;
			writer.write_token("lm-aggregation");
			writer.write_integer(writer.get_lm_id(Current));
			writer.write_integer(writer.get_lm_id(source));
			writer.write_integer(writer.get_lm_id(destination));
			writer.write_token(destination_attributes.multiplicity.name);
			writer.right_paren;
			writer.new_line;
		end;

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
			id_str, source_str,
			dest_str, dest_mult_str : 			STRING;
			src, dest : LOGICAL_MODEL_ITEM;
		do
			if args.count /= 4 then
				reader.error("Incorrect number of arguments for aggregation");
			end;
			id_str ?= args @ 1;
			source_str ?= args @ 2;
			dest_str ?= args @ 3;
			dest_mult_str ?= args @ 4
			if source_str = Void or else dest_str = Void
			   or else dest_mult_str = Void
			   or else (not source_str.is_integer) 
			   or else (not dest_str.is_integer)
			   or else (source_str.to_integer < 1)
			   or else (dest_str.to_integer < 1)
		    then
				reader.error("Error in arguments to aggregation");
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
				reader.error("Error in arguments to association");
			end;
			!!destination_attributes.make;
			init_class_relationship(src, dest);
			set_destination_multiplicity(mult_from_string(dest_mult_str));
			reader.check_id_str(id_str);
			force_i_th_item(reader, Current, id_str.to_integer);
		end;


end -- class LM_AGGREGATION
