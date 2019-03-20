deferred class CIRCLE_DECORATION
	-- A decoration that is in the form of a circle

inherit

	CONNECTION_DECORATION
		redefine
			span_start,
			place_items,
			populate_diagram,
			release_tk_items
		end;


feature		-- Initialize/Release


	make (d : DIAGRAM) is
		do
			init_connection_decoration(d);
		end;


feature		-- Query

	span_start : POINT is
		do
			Result := orienter.map_point(endpoint, diameter, 0);
		end;

feature		-- Drawing

	place_items is
			-- Move the Tk objects to a new position on the diagram.
		local
			p1, p2 : POINT;
		do
			p1 := orienter.map_point(endpoint, 1, -((diameter - 1) // 2));
			p2 := orienter.map_point(endpoint, diameter, 
											   ((diameter - 1) // 2));
			circle.set_coords(p1.x, p1.y, p2.x, p2.y);
				-- circle doesn't care whether x1 > x2 or x2 > x1
		end;


feature	{ CONNECTION_DECORATION }	-- Implementation

	circle : CANVAS_OVAL;		-- The circle we draw on the diagram

	diameter : INTEGER is		-- This should probably be odd.
		deferred
		end;


	populate_diagram is
			-- Create any necessary Tk objects
		do
			!!circle.make(diagram.canvas);
			set_circle_attributes;
		end;

	release_tk_items is
		do
			circle.release
		end;

	set_circle_attributes is
			-- Set attributes of the circle, like outline width and fill color.
			-- We do *not* necessarily have an orienter at this point, so
			-- don't try to place the circle.
		deferred
		end;

end -- class CIRCLE_DECORATION
