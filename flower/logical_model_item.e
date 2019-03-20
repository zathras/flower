deferred class LOGICAL_MODEL_ITEM 
	-- This abstract class represents any item in a logical model.  Items might
	-- be classes, objects, relationships, or anything else out of which a
	-- logical model is made.
	--
	-- A LOGICAL_MODEL_ITEM represents the item itself, *not* its 
	-- representation on a drawing.  That is handled by the DRAWABLE class.

	inherit
		OBSERVABLE;
		PROJECT_STREAMABLE




feature		-- Initialize/Release

	init_item (a_logical_model : LOGICAL_MODEL) is
		require
			logical_model_supplied : a_logical_model /= Void
		do
			init_observable;
			logical_model := a_logical_model
			!!relationships.make(0);
		end;


feature		-- Modification


	add_relationship (r : LM_RELATIONSHIP) is
		do
			relationships.extend(r);
		end;

feature		-- Editing

	can_be_edited : BOOLEAN is
			-- Can this item be edited?
		do
			Result := False;
		end;

	launch_editor is
			-- Launch an editor for this item
		require
			can_be_edited : can_be_edited;
		do
		end;

feature		-- Attributes

	logical_model : LOGICAL_MODEL;	-- The logical model of which we're a part

	relationships : ARRAYED_LIST [ LM_RELATIONSHIP ];


feature { LOGICAL_MODEL_ITEM }		-- Streaming support

	force_i_th_item (reader : PROJECT_READER; item: LOGICAL_MODEL_ITEM;
				    i : INTEGER) is
		local
			items : ARRAYED_LIST [ LOGICAL_MODEL_ITEM ];
		do
			items := reader.project.logical_model.items
			from until items.count >= i loop
				items.extend(Void);
			end
			items.put_i_th(Current, i);
		end;

end -- class LOGICAL_MODEL_ITEM
