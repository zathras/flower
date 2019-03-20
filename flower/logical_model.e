class LOGICAL_MODEL 
	-- Represents the logical model that the ensemble of diagrams
	-- portrays.  cf. LOGICAL_MODEL_ITEM.


creation

	make

feature		-- Initialize/Release

	make (an_app : FLOWER_MAIN) is
		do
			app := an_app;
			!!items.make(0);
		end;


feature		-- Item Retrieval

	class_named (a_name : STRING) : LM_CLASS is
		-- Deliver a class named a_name.  If one doesn't already exist,
		-- create it first.
		local
			i : INTEGER;
			a_class : LM_CLASS;
		do
				-- This is called rarely enough that speed isn't very
				-- important.
			from i := 1 until Result /= Void or else i > items.count loop
				a_class ?= items @ i;
				if (a_class /= Void) and then (a_class.name.is_equal(a_name))
				then
					Result := a_class
				end
				i := i + 1;
			end  -- loop
			if Result = Void then
				!!a_class.make(Current, a_name);
				items.extend(a_class);
				Result := a_class;
			end
		end;


feature -- Attributes

	items : ARRAYED_LIST [ LOGICAL_MODEL_ITEM ];

	app : FLOWER_MAIN;		-- The application of which we're a part


feature  { LOGICAL_MODEL } -- Implementation

	tk_app : TK_APPLICATION is
		do
			Result := app.tk_app;
		end;


end -- class LOGICAL_MODEL
