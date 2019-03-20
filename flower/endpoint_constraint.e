deferred class ENDPOINT_CONSTRAINT
	-- Represents a constraint placed on a span endpoint.  Endpoint constraints
	-- know how to constrain the x,y position of an endpoint, and know about
	-- any constraint(s) that should apply to spans connected to their
	-- endpoints due to the nature of the endpoint.



feature		-- Querying

	span_violates_constraints (a_span : SPAN) : BOOLEAN is
			-- Does a_span violate any constraint(s) placed on it by the
			-- nature of this endpoint?
		deferred
		end;

	constrains_point_to(a_solid : SOLID) : BOOLEAN is 
			-- Does this constraint tie its endpoint to a_solid?
		deferred
		end;

	requires_vertical_spans : BOOLEAN is
			-- Must new spans from this point be vertical?
		deferred
		end;

	requires_horizontal_spans : BOOLEAN is
			-- Must new spans from this point be horizontal?
		deferred
		end;


		-- Minimal and maximal x and y coordinates, according to the
		-- constraint.

	min_x : INTEGER is
		deferred
		end;

	max_x : INTEGER is
		deferred
		end;

	min_y : INTEGER is
		deferred
		end;

	max_y : INTEGER is
		deferred
		end;

	constraining_solid : SOLID is
			-- Give the solid on which this constraint is based, or Void
			-- if there is none.
		do
			Result := Void;
		end;

feature { SPAN_ENDPOINT }		-- Streaming support

	write_for_writer (writer : PROJECT_WRITER) is
		deferred
		end;


end -- class ENDPOINT_CONSTRAINT
