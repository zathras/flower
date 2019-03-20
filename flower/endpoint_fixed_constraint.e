class ENDPOINT_FIXED_CONSTRAINT 
	-- Represents an ENDPOINT_CONSTRAINT due to the user clicking at
	-- a given point on the canvas.

	inherit
		ENDPOINT_CONSTRAINT
			redefine
				span_violates_constraints,
				constrains_point_to,
				requires_vertical_spans,
				requires_horizontal_spans,
				min_x, max_x, min_y, max_y,
				write_for_writer
			end;

creation

	make

feature		-- Initialize/Release

	make (an_x, a_y : INTEGER) is
		do
			x := an_x;
			y := a_y;
		end;


feature		-- Querying

	span_violates_constraints(a_span : SPAN) : BOOLEAN is
        -- Spans connected to fixed endpoints are unconstrained
		do
			Result := False
		end;

	constrains_point_to(a_solid : SOLID) : BOOLEAN is
		do
			Result := False
		end;

	requires_vertical_spans : BOOLEAN is False;

	requires_horizontal_spans : BOOLEAN is False;

	min_x : INTEGER is do Result := x end;
	max_x : INTEGER is do Result := x end;
	min_y : INTEGER is do Result := y end;
	max_y : INTEGER is do Result := y end;

feature { SPAN_ENDPOINT }		-- Streaming support

	write_for_writer (writer : PROJECT_WRITER) is
		do
			writer.write_token("solid-fixed");
		end;


feature { NONE }		-- Implementation

	x : INTEGER;
	y : INTEGER;

end -- class ENDPOINT_FIXED_CONSTRAINT
