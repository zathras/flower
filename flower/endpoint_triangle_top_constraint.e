class ENDPOINT_TRIANGLE_TOP_CONSTRAINT 
	-- Represents a constraint that holds a span endpoint at the top of
	-- an INHERITANCE_TRIANGLE


inherit
	ENDPOINT_CONSTRAINT
		redefine
			min_x, max_x, min_y, max_y,
			requires_vertical_spans,
			requires_horizontal_spans,
			span_violates_constraints,
			constrains_point_to,
			constraining_solid,
			write_for_writer
		end;


creation

	make


feature		-- Initialize/Release

	make(a_triangle : INHERITANCE_TRIANGLE) is
		do
			triangle := a_triangle;
		end;


feature		-- Querying

	span_violates_constraints (a_span : SPAN) : BOOLEAN is
		-- cf. ENDPOINT_CONSTRAINT
		do
			Result := False;
				-- If they really want to, they can make a span that
				-- goes through us.
		end;

	constrains_point_to(a_solid : SOLID) : BOOLEAN is 
		do
			Result := a_solid = triangle
		end;

	requires_vertical_spans : BOOLEAN is True;

	requires_horizontal_spans : BOOLEAN is False;

	min_x : INTEGER is do Result := triangle.top_x end;
	max_x : INTEGER is do Result := triangle.top_x end;
	min_y : INTEGER is do Result := triangle.top end;
	max_y : INTEGER is do Result := triangle.top end;

	constraining_solid : SOLID is
		do
			Result := triangle;
		end;


feature { SPAN_ENDPOINT }		-- Streaming support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			id : INTEGER;
		do
			writer.write_token("triangle-top");
			id := writer.get_drawable_id(triangle);
			writer.write_integer(id);
		end;


feature { ENDPOINT_TRIANGLE_TOP_CONSTRAINT } -- Implementation

	triangle : INHERITANCE_TRIANGLE;
		-- The triangle to which we constrain the endpoint

end -- class ENDPOINT_TRIANGLE_TOP_CONSTRAINT
