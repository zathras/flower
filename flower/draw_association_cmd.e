class DRAW_ASSOCIATION_CMD
	-- Handles a series of mouse left button clicks for a CONTROLLER that
	-- are tracing the lines of an association.

inherit

	DRAW_MANHATTAN_CONNECTION_CMD
		redefine
			create_relationship
		end;

creation

	make


feature { DRAW_MANHATTAN_CONNECTION_CMD }	-- Superclass overrides

	create_relationship (src, dest : LOGICAL_MODEL_ITEM) : LM_RELATIONSHIP is
		do
			!LM_ASSOCIATION!Result.make(src, dest);
		end;

end -- class DRAW_ASSOCIATION_CMD
