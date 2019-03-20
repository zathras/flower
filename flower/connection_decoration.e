deferred class CONNECTION_DECORATION
	-- Represents a decoration that is added to an endpoint of a
	-- CONNECTION.


feature		-- Initialize/Release

	init_connection_decoration (d : DIAGRAM) is
		do
			diagram := d;
			populate_diagram;
		end;

	release is
		do
			release_tk_items;
			if endpoint.decoration = Current then
				endpoint.set_decoration(Void);
			end
		end;


feature		-- Query

	span_start  : POINT is
			-- Give the position where the span's line should start
		deferred
		end;

feature		-- Modification

	set_endpoint (ep : SPAN_ENDPOINT) is
		do
			endpoint := ep;
			ep.set_decoration(Current);
		end;

	set_orienter (o : DECORATION_ORIENTER) is
		do
			orienter := o;
		end;


feature		-- Drawing

	place_items is
			-- Move the Tk objects to a new position on the diagram.
		deferred
		end;


feature		-- Attributes

	diagram : DIAGRAM;			-- The diagram on which we're drawn

	endpoint : SPAN_ENDPOINT;	-- The endpoint to which we're attached

	orienter : DECORATION_ORIENTER;  -- The object we use to orient drawing


feature	{ CONNECTION_DECORATION }	-- Implementation

	populate_diagram is
			-- Create any necessary Tk objects
		deferred
		end;

	release_tk_items is
			-- Remove any Tk objects that were created
		deferred
		end;

end -- class CONNECTION_DECORATION
