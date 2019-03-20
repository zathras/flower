class MULTIPLICITY_ONE 
	-- Represents a multiplicity of "one"


inherit
	MULTIPLICITY
		redefine
			name,
			is_decoration_for,
			make_decoration_for
		end;

creation

	make


feature		-- Attributes

	name : STRING is "one";

feature		-- Decoration Management

	is_decoration_for (diagram : DIAGRAM;
					   decor : CONNECTION_DECORATION) : BOOLEAN is
		do
			Result := diagram.is_mult_one_decoration(decor)
		end;

	make_decoration_for (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Make the right kind of decoriation for this multiplicity.
		do
			Result := diagram.make_mult_one_decoration;
		end;

end -- class MULTIPLICITY_ONE
