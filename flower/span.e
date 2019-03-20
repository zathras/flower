deferred class SPAN
	-- Represents one or more lines connecting two points.  Typically, one
	-- or more spans will be used to draw a relationship.

inherit
	PROJECT_STREAMABLE
		redefine
			write_for_writer
		end;

feature		-- Modification


	move_destination (x : INTEGER; y : INTEGER) is
			-- Moves the destination to (x,y).  This might violate the
			-- constraint...  Clients should check this (by calling
			-- constraint_violated), and take appropriate action if 
			-- it is violated.
		deferred
		end;

	set_source (an_endpoint : SPAN_ENDPOINT) is
		do
			source := an_endpoint
		end;

	set_destination (an_endpoint : SPAN_ENDPOINT) is
		do
			destination := an_endpoint
		end;

	relax_span_constraints is
			-- Relax any span-specific constraints.
		do
		end;

	merge_colinear_part(other : like Current) : BOOLEAN is
			-- If Current and other have a part that is colinear, make Current
			-- take over that part.  This also has the effect of eliminating
			-- "T"'s, where a span doubles back on itself.
			-- Return True iff modified
		require
			connected: Current.destination = other.source;
		deferred
		end;

	mirror is
			-- Make our source be our destination, and vice-versa
		local
			tmp : SPAN_ENDPOINT;
		do
			tmp := source;
			source := destination;
			destination := tmp;
			note_moved_endpoints;
		end;

	note_moved_endpoints is
			-- Someone external has moved our endpoints, so we should
			-- re-draw our lines to match.
		deferred
		end;

	release is			-- Remove the span from the screen
		deferred
		end;


feature		-- Querying


	constraint_violated : BOOLEAN is
		do
			Result := source.span_violates_constraints(Current)
						or else destination.span_violates_constraints(Current);
		end;

	midpoint_x : INTEGER is
		deferred
		end;

	midpoint_y : INTEGER is
		deferred
		end;

	is_straight_line : BOOLEAN is
		deferred
		end;

	is_vertical : BOOLEAN is
		do
			Result := source.x = destination.x
		end;

	is_horizontal : BOOLEAN is
		do
			Result := source.y = destination.y
		end;

	contains (x, y : INTEGER) : BOOLEAN is
			-- Is the point x,y within selection_slop of a line that 
			-- represents this connection?
		deferred
		end;

	select_it (x, y : INTEGER) is
			-- Mark the part of the span under (x,y) as selected
		require
			contains_point : contains(x, y)
		deferred
		end;

	transfer_selection_from (other : like current) : BOOLEAN is
			-- Transfer any state associated with the selection from
			-- other to ourselves.  Return True if this was done, or
			-- false if it doesn't make sense to do so.
		require
			connected: source = other.destination
							or else destination = other.source
		deferred
		end;

	deselect is
		deferred
		end;

feature		-- Attributes

	source : SPAN_ENDPOINT;
	destination : SPAN_ENDPOINT;
	canvas : TK_CANVAS;

feature		-- Streaming support

	init_from_reader (a_canvas : TK_CANVAS) is
		deferred
		end;

feature { CONNECTION }	-- Streaming support

	write_for_writer (writer : PROJECT_WRITER) is
		deferred
		end;

feature	{ SPAN }	-- Protected

	set_canvas (a_canvas : TK_CANVAS) is
		do
			canvas := a_canvas
		end;

	selection_slop : INTEGER is 2;
		-- In tests for whether lines contain points, a slop of +- this many
		-- pixels will be allowed.

end -- class SPAN
