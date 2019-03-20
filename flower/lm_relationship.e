deferred class LM_RELATIONSHIP 
	-- This abstract class is used to represent relationships between
	-- logical_model_items.  Relationships are always binary.

inherit

	LOGICAL_MODEL_ITEM;
	EXCEPTIONS

feature			-- Initialize/Release

	init_relationship (src, dest : LOGICAL_MODEL_ITEM) is
		do
			source := src;
			destination := dest;
			init_item (src.logical_model);
			source.add_relationship(Current);
			destination.add_relationship(Current);
		end;

feature		-- Multiplicity mapping

		-- Singleton objects to represent multiplicities:

	mult_one      : MULTIPLICITY is once !MULTIPLICITY_ONE!Result.make end;
	mult_optional : MULTIPLICITY is once !MULTIPLICITY_OPTIONAL!Result.make end;
	mult_many     : MULTIPLICITY is once !MULTIPLICITY_MANY!Result.make end;

	mult_from_string (s : STRING) : MULTIPLICITY is
		do
			if s.is_equal("one") then
				Result := mult_one;
			elseif s.is_equal("optional") then
				Result := mult_optional;
			elseif s.is_equal("many") then
				Result := mult_many;
			else
				raise ("Invalid multiplicity value:  should be one, optional, or many");
			end
		end;

	mult_to_string (m : MULTIPLICITY) : STRING is
		do
			Result := m.name;
		end


feature			-- Attributes

	source : LOGICAL_MODEL_ITEM;
	destination : LOGICAL_MODEL_ITEM;


	source_attributes : LM_RELATIONSHIP_END_ATTRIBUTES is
			-- Subclasses with source attributes should override
		do
			Result := Void
		end;

	destination_attributes : LM_RELATIONSHIP_END_ATTRIBUTES is
			-- Subclasses with destination attributes should override
		do
			Result := Void
		end;

	has_source_attributes : BOOLEAN is
		do
			Result := source_attributes /= Void
		end

	has_destination_attributes : BOOLEAN is
		do
			Result := destination_attributes /= Void
		end

feature		-- Modification

	set_source_multiplicity (m : MULTIPLICITY) is
		require
			has_source_attributes : has_source_attributes
		do
			-- Subclasses with source attributes should override
		end;

	set_destination_multiplicity (m : MULTIPLICITY) is
		require
			has_destination_attributes : has_destination_attributes
		do
			-- Subclasses with destination attributes should override
		end;

feature { CONNECTION }	-- Decoration Management

	-- These features are used by connections to manage the decorations
	-- that parameters of the relationship that they represent can
	-- demand.

	source_decoration_ok (diagram : DIAGRAM;
						  decoration : CONNECTION_DECORATION) : BOOLEAN is
			-- Is this this right kind of decoration for the give diagram?
		deferred
		end;

	make_source_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		deferred
		end;

	destination_decoration_ok (diagram : DIAGRAM;
							   decoration : CONNECTION_DECORATION) : BOOLEAN is
			-- Is this this right kind of decoration for the give diagram?
		deferred
		end;

	make_destination_decoration (diagram : DIAGRAM) : CONNECTION_DECORATION is
			-- Create the right kind of decoration (which might be Void)
		deferred
		end;


end -- class LM_RELATIONSHIP
