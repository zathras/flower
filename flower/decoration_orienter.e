deferred class DECORATION_ORIENTER
	-- Represents an object that is used to orient the decoration
	-- of a connection.  A bit of an explanation is in order here:
    -- 
    -- CONNECTION_DECORATION objects are used to decorate the ends of 
    -- connections.  The indicate things like aggregation and cardinality.  
    -- 
    -- The code within a decoration pretends that it is drawing the 
    -- decoration coming out of the right side of a box, extending 
    -- horizontally.  To orient the decoration properly, the 
    -- decoriation mediates all of its points through a 
    -- DECORATION_ORIENTER, which is responsible for making 
    -- it point the right way.  CONNECTION objects are responsible
    -- for selecting the right kind of DECORATION_ORIENTER for their
    -- decorations.


feature { CONNECTION_DECORATION }	-- Point mapping

	map_point (ep : SPAN_ENDPOINT; dx, dy : INTEGER) : POINT is
			-- This is a bit subtle.  Maps a point that is (dx, dy) away
			-- from the endpoint ep.  (dx, dy) is rotated as determined
			-- by the kind of orienter this is.
		deferred
		end;



end -- class DECORATION_ORIENTER
