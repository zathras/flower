class FILLED_CIRCLE_DECORATION
	-- A decoration that is a filled-in circle (like the Rumbaugh symbol
	-- for a multiplicity of "many")

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
			circle.set_outline_width(1);
			circle.set_fill_color("black");
		end;

end	-- class FILLED_CIRCLE_DECORATION
