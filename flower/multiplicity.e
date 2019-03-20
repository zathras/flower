deferred class MULTIPLICITY 
	-- Represents the multiplicity of part of an association.
	-- Subclasses are all singletons that are instantiated
	-- from within LM_RELATIONSHIP


feature { LM_RELATIONSHIP }		-- Initialize/Release

	make is
		do
		end;

feature		-- Attributes

	name : STRING is
		deferred
		end;

feature		-- Decoration Management

	is_decoration_for (diagram : DIAGRAM;
					   decor : CONNECTION_DECORATION) : BOOLEAN is
			-- Does decor represent this kind of multiplicity?
		deferred
		end;

	make_decoration_for (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Make the right kind of decoriation for this multiplicity.
		deferred
		end;

end -- class MULTIPLICITY
