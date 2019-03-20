class LINE_SEGMENT 
	-- Represents the abstract idea of a 2D line segment with integral
	-- coordinates.  This is used for things like intersection tests.


creation

	make, make_uninitialized

feature		-- Initialize/Release

	make (a_x1 : INTEGER; a_y1 : INTEGER; a_x2 : INTEGER; a_y2 : INTEGER) is
		do
			set_coordinates(a_x1, a_y1, a_x2, a_y2);
		end;

	make_uninitialized is
		do
		end;

feature		-- Attributes

	x1 : INTEGER;		-- Yes, I could have used POINTs, but IMHO that's
	y1 : INTEGER;		-- more bother than it's worth.
	x2 : INTEGER;
	y2 : INTEGER;

	p1 : POINT is
		do
			!!Result.make(x1, y1)
		end;

	p2 : POINT is
		do
			!!Result.make(x2, y2)
		end;

	xmin : INTEGER is
		do
			Result := x1.min(x2);
		end;

	xmax : INTEGER is
		do
			Result := x1.max(x2);
		end;

	ymin : INTEGER is
		do
			Result := y1.min(y2);
		end;

	ymax : INTEGER is
		do
			Result := y1.max(y2);
		end;


feature		-- Querying 

	intersection_point (other : LINE_SEGMENT) : POINT is
			-- Find the point at which Current intersects with Other.  If
			-- they don't intersect, return Void.  If they are parallel
			-- returns Void, even if the lines are co-linear.
		local
			a1 : INTEGER;	-- as in the equation of a line,
			a2 : INTEGER;	-- "a*x + b*y = c"
			b1 : INTEGER;
			b2 : INTEGER;
			c1 : INTEGER;
			c2 : INTEGER;
			denom : INTEGER;	-- a1*b2 - a2*b1
			x : DOUBLE;
			y : DOUBLE;
			xr : INTEGER;
			yr : INTEGER;
		do
			-- We do most of our arithmatic in integral coordinates.  With
			-- maximal canvas sizes around 2K by 2K, and 32 bit integers
			-- there is plenty of room in INTEGER for our intermediate
			-- results, and this way we don't have to worry about
			-- numerical instability near zero for division.
			a1 := y2 - y1;
			b1 := x1 - x2;
			c1 := (a1 * x1) + (b1 * y1);
			a2 := other.y2 - other.y1;
			b2 := other.x1 - other.x2;
			c2 := (a2 * other.x1) + (b2 * other.y1);

			denom := (a1 * b2) - (a2 * b1);

			if denom /= 0 then		-- If lines aren't parallel
				x := ((b2 * c1) - (b1 * c2)) / denom;
				y := ((a1 * c2) - (a2 * c1)) / denom;
				xr := x.rounded;
				yr := y.rounded;

				if xr >= xmin and then xr <= xmax 
					and then yr >= ymin and then yr <= ymax
					and then xr >= other.xmin and then xr <= other.xmax
					and then yr >= other.ymin and then yr <= other.ymax
				then
					!!Result.make(xr, yr);
				end
  			end
		end;

feature		-- Modification


	set_coordinates (a_x1 : INTEGER; a_y1 : INTEGER; 
				     a_x2 : INTEGER; a_y2 : INTEGER) is
		do
			x1 := a_x1;
			y1 := a_y1;
			x2 := a_x2;
			y2 := a_y2;
		end;


end -- class LINE_SEGMENT
