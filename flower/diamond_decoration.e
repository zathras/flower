class DIAMOND_DECORATION
	-- A decoration that is in the form of a diamond (like is used
	-- for aggregation in Rumbaugh, but this is the wrong level
	-- to talk about types of diagrams :-)

inherit

	CONNECTION_DECORATION
		redefine
			span_start,
			place_items,
			populate_diagram,
			release_tk_items
		end;

creation

	make

feature		-- Initialize/Release


	make (d : DIAGRAM) is
		do
			init_connection_decoration(d);
		end;


feature		-- Query

	span_start : POINT is
		do
			Result := orienter.map_point(endpoint, 2 * long_offset, 0);
		end;

feature		-- Drawing

	place_items is
			-- Move the Tk objects to a new position on the diagram.
		local
			p0, p : POINT;
			coords : ARRAYED_LIST [ POINT ];
		do
			!!coords.make(5);
			!!p0.make(endpoint.x, endpoint.y);
			coords.extend(p0);
			p := orienter.map_point(endpoint, long_offset, short_offset);
			coords.extend(p);
			p := orienter.map_point(endpoint, 2*long_offset, 0);
			coords.extend(p);
			p := orienter.map_point(endpoint, long_offset, -short_offset);
			coords.extend(p);
			coords.extend(p0);	-- i.e. back to the origin

			outline.set_coord_list(coords);
		end;


feature	{ CONNECTION_DECORATION }	-- Implementation

	outline : CANVAS_LINE;		-- The outline of the diamond

	short_offset : INTEGER is 5;  -- The offset along the short direction
								  -- (i.e. half the width)

	long_offset : INTEGER is 10;  -- The offset along the long direction
								  -- (i.e. half the length)


	populate_diagram is
			-- Create any necessary Tk objects
		do
			!!outline.make(diagram.canvas);
			outline.set_width(2);
		end;

	release_tk_items is
		do
			outline.release
		end;

end -- class DIAMOND_DECORATION
