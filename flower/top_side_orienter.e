class TOP_SIDE_ORIENTER
	-- Represents an ORIENTER that orients a decoration extending vertically
	-- from the top side of a box.

inherit

	DECORATION_ORIENTER
		redefine
			map_point
		end;

feature { CONNECTION_DECORATION }	-- Point mapping

	map_point (ep : SPAN_ENDPOINT; dx, dy : INTEGER) : POINT is
		do
			!!Result.make(ep.x - dy, ep.y - dx);
		end;

end -- class TOP_SIDE_ORIENTER
