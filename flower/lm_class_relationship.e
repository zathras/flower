deferred class LM_CLASS_RELATIONSHIP 
	-- Represents relationships between two classes

inherit

	LM_RELATIONSHIP

feature	-- Initialize/Release

	init_class_relationship (src, dest : LOGICAL_MODEL_ITEM) is
		do
			init_relationship(src, dest);
		end;


feature		-- Attributes

	source_class : LM_CLASS is
		do
			Result ?= source
		end;

	destination_class : LM_CLASS is
		do
			Result ?= destination
		end;

feature { LM_CLASS_RELATIONSHIP }		-- Implementation

	editor : EDIT_RELATIONSHIP_DIALOG is
		once
			!!Result.make(logical_model.app.tk_app);
				-- Not all kinds of relationships necessarily use this dialog.
		end;


end -- class LM_CLASS_RELATIONSHIP
