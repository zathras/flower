class RUMBAUGH_DIAGRAM
	-- Represents a rumbaugh diagram

	inherit
		DIAGRAM
			redefine
				is_mult_one_decoration,
				is_mult_optional_decoration,
				is_mult_many_decoration,
				is_aggregation_decoration,
				make_mult_one_decoration,
				make_mult_optional_decoration,
				make_mult_many_decoration,
				make_aggregation_decoration,
				name_for_writer
			end;

creation

	make,
	make_for_reader


feature		-- Item Control

	is_mult_one_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		do
			Result := (d = Void);
				-- In Rumbaugh, a multiplicity of one is expressed by
				-- having no decoration
		end;

	is_mult_optional_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		local
			target : OPEN_CIRCLE_DECORATION;
		do
			target ?= d;
			Result := (target /= Void);
		end;

	is_mult_many_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		local
			target : FILLED_CIRCLE_DECORATION;	
		do
			target ?= d;
			Result := (target /= Void);
		end;

	is_aggregation_decoration (d : CONNECTION_DECORATION) : BOOLEAN is
		local
			target : DIAMOND_DECORATION;
		do
			target ?= d;
			Result := (target /= Void);
		end;

	make_mult_one_decoration : CONNECTION_DECORATION is
		do
			Result := Void;
		end;

	make_mult_optional_decoration  : CONNECTION_DECORATION is
		do
			!OPEN_CIRCLE_DECORATION!Result.make(Current);
		end;

	make_mult_many_decoration  : CONNECTION_DECORATION is
		do
			!FILLED_CIRCLE_DECORATION!Result.make(Current);
		end;

	make_aggregation_decoration : CONNECTION_DECORATION is
		do
			!DIAMOND_DECORATION!Result.make(Current);
		end;

feature { DIAGRAM }		-- Streaming Support


	name_for_writer : STRING is
		do
			Result := "rumbaugh-diagram"
		end;

end -- class RUMBAUGH_DIAGRAM
