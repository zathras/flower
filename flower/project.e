class PROJECT
	-- Represents the project being edited, that is, the combination of
	-- the logical model and all of the diagrams.

creation

	make

feature	-- Initialize/Release

	make (app : FLOWER_MAIN) is
		do
			int_next_diagram_id := 1;
			!!logical_model.make(app);
			!!diagrams.make(10);
		end;

	release is
		local
			i : INTEGER;
		do
			from i := 1 until i > diagrams.count loop
				(diagrams @ i).release;
				i := i + 1
			end
		end;
	


feature 			-- Diagram Manipulation

	add_diagram(a_diagram : DIAGRAM) is
		require
			is_unique: find_diagram(a_diagram.id) = Void
		do
			diagrams.put(a_diagram, a_diagram.id);
		end;


	find_diagram(an_id : INTEGER) : DIAGRAM is		
			-- Find a diagram by id, Void if not found.
		do
			Result := diagrams @ an_id;
		end;

	diagrams_count : INTEGER is
		do
			Result := diagrams.count
		end;

	diagrams_as_arrayed_list : ARRAYED_LIST [ DIAGRAM ] is
		do
			Result := diagrams.linear_representation;
		end;

feature			-- Attributes

	logical_model : LOGICAL_MODEL;

	next_diagram_id : INTEGER is	-- Generate a unique id for a diagram
		do
			Result := int_next_diagram_id;
			int_next_diagram_id := int_next_diagram_id + 1;
		end;


feature { NONE }	-- Private

	int_next_diagram_id : INTEGER	-- Internal next diagram id

	diagrams : HASH_TABLE [ DIAGRAM, INTEGER ];		
		-- Manages diagrams by id.


end -- class PROJECT
