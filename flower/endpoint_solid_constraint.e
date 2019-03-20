deferred class ENDPOINT_SOLID_CONSTRAINT 
	-- Represents an ENDPOINT_CONSTRAINT due to an endpoint being
	-- connected to a side of a SOLID.  Has four subclasses, for
	-- endpoints attached to the top, bottom, left, or right of a solid.

	inherit
		ENDPOINT_CONSTRAINT
			redefine
				constrains_point_to
			end;


feature		-- Initialize/Release

	make (a_solid : SOLID) is
		do
			solid := a_solid;
		end;

feature		-- Querying

	constrains_point_to(a_solid : SOLID) : BOOLEAN is
		do
			Result := a_solid.bounding_box = bounding_box;
		end;

	decoration_orienter : DECORATION_ORIENTER is
			-- Delivers a decoration orienter that will orient decorations
			-- the right way for a point attached to the side of the SOLID
			-- that we represent.
		deferred
		end;

feature { ENDPOINT_SOLID_CONSTRAINT }		-- Implementation

	solid : SOLID;
			-- The solid to which we're constrained


	bounding_box : BOUNDING_BOX is
		-- The bounding box to which we're constrained
		do
			Result := solid.bounding_box;
		end;

end -- class ENDPOINT_SOLID_CONSTRAINT
