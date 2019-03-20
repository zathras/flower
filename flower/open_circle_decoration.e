class OPEN_CIRCLE_DECORATION
	-- A decoration that is a circle outline (like the Rumbaugh symbol
	-- for a multiplicity of "optional")

inherit

	CIRCLE_DECORATION
		redefine
			diameter,
			set_circle_attributes
		end;


creation

	make


feature	{ CONNECTION_DECORATION }	-- Implementation

	diameter : INTEGER is 7;

	set_circle_attributes is
		do
			circle.set_outline_width(2);
		end;

end	-- class OPEN_CIRCLE_DECORATION
