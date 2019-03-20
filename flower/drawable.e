deferred class DRAWABLE
	-- Represents a drawable item that appears on a DIAGRAM.  DRAWABLEs
	-- often represent parts of the logical model (LM_ITEMs), though there are
	-- some that don't (like, say, the Rumbaugh inheritance triangle).
	-- In general, the structure of DRAWABLEs is similar to the logical model,
	-- but neither is derivable from the other.

inherit 

	PROJECT_STREAMABLE
		redefine
			write_for_writer
		end;

feature		-- Initialize/Release

	init_drawable(d : DIAGRAM) is
		do
			if d /= Void then
				diagram := d;
				d.add_drawable(Current);
			end
		end;


feature		-- Querying

	contains(x : INTEGER; y : INTEGER) : BOOLEAN is
		deferred
		end;

	bounding_box : BOUNDING_BOX is
		deferred
		end;

	selected : BOOLEAN;		-- Is this drawable currently selected?

	supports_direct_drag : BOOLEAN is
			-- Does this drawable support direct drag (through move_selected)?
		do
			Result := False		-- By default, no.
		end;

	logical_model_item : LOGICAL_MODEL_ITEM is
			-- Give the logical model item associated with this drawable, if
			-- it has one.
		do
			Result := Void
		end;


feature		-- Modification

	deselect is
		deferred
		end;

	single_select (x, y : INTEGER) is
		-- Notify the object that it is selected.  x,y gives the position of
		-- the mouse event that caused the selection.
		require
			contain_point : contains(x, y)
		deferred
		ensure
			selected: selected		-- single_select always selects it.
		end;

	attempt_multiple_select is
		-- Attempt to select the item as part of a multiple selection.  
		-- Drawables may refuse to be so selected, so it's the client's
		-- responsability to query selected after doing this.
		deferred
		end;

	move_selected (delta_x : INTEGER; delta_y : INTEGER) is
		require
			selected : selected;
		deferred
		end;

	finalize_placement is
		-- Called when something has finished moving.
		do
		end;

feature { DIAGRAM }		-- Streaming support

	init_from_reader (a_diagram : DIAGRAM) is
		deferred
		end;

	write_for_writer (writer : PROJECT_WRITER) is
		deferred
		end;
			-- Here, I'm just changing the visibility.

feature { DRAWABLE }	-- Protected

	diagram : DIAGRAM;		-- The diagram we're displayed on.

	tk_app : TK_APPLICATION is
		do
			Result := diagram.tk_app;
		end;


	set_diagram (d : DIAGRAM) is
		require 
			diagram_not_set : diagram = Void
		do
			diagram := d;
		end;

end -- class DRAWABLE
