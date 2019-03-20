class RIGHT_SIDE_ORIENTER
	-- Represents an ORIENTER that orients a decoration extending horizontally
	-- from the right side of a box.

inherit

	DECORATION_ORIENTER
		redefine
			map_point
		end;

feature { CONNECTION_DECORATION }	-- Point mapping

	map_point (ep : SPAN_ENDPOINT; dx, dy : INTEGER) : POINT is
		do
			!!Result.make(ep.x + dx, ep.y + dy);
		end;

end -- class RIGHT_SIDE_ORIENTER
