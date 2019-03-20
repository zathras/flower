class LM_RELATIONSHIP_END_ATTRIBUTES 
	-- Represents the attribute(s) attached to an end of an LM_RELATIONSHIP.


creation

	make

feature		-- Initialize/Release

	make is
		do
		end;

feature		-- Attributes

	multiplicity : MULTIPLICITY;	-- cf. Multiplicity mappings in
									-- LM_RELATIONSHIP.

			-- @@ Eventually, add role.

feature	{ LM_RELATIONSHIP }	-- Modification

	set_multiplicity (m : MULTIPLICITY) is
		do
			multiplicity := m;
		end;

end -- class LM_RELATIONSHIP_END_ATTRIBUTES
