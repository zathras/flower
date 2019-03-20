class ENDPOINT_SOLID_BOTTOM_CONSTRAINT 


inherit
	ENDPOINT_SOLID_CONSTRAINT
		redefine
			min_x, max_x, min_y, max_y,
			requires_vertical_spans,
			requires_horizontal_spans,
			span_violates_constraints,
			write_for_writer
		end;
	BOTTOM_SIDE_ORIENTER
		-- A mixin that allows us to directly orient points for a connection


creation

	make


feature		-- Querying

	span_violates_constraints (a_span : SPAN) : BOOLEAN is
		-- cf. ENDPOINT_CONSTRAINT
		do
			Result := a_span.destination.y < bounding_box.bottom
					  or else a_span.source.y < bounding_box.bottom;
		end;

	requires_vertical_spans : BOOLEAN is True;

	requires_horizontal_spans : BOOLEAN is False;

	min_x : INTEGER is do Result := bounding_box.left end;
	max_x : INTEGER is do Result := bounding_box.right end;
	min_y : INTEGER is do Result := bounding_box.bottom end;
	max_y : INTEGER is do Result := bounding_box.bottom end;

	decoration_orienter : DECORATION_ORIENTER is
		do
			Result := Current;	-- cf. the Mixin, in the inheritance section
		end;


feature { SPAN_ENDPOINT }		-- Streaming support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			id : INTEGER;
		do
			writer.write_token("solid-bottom");
			id := writer.get_solid_id_from_bounding_box(bounding_box);
			writer.write_integer(id);
		end;


end -- class ENDPOINT_SOLID_BOTTOM_CONSTRAINT
