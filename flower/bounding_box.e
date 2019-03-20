class BOUNDING_BOX

creation

	make

feature		-- Initialize/Release

	make(a_left : INTEGER; a_top: INTEGER; 
		 a_width : INTEGER; a_height : INTEGER) is
		do
			left := a_left;
			top := a_top;
			width := a_width;
            height := a_height;
		end;

feature		-- Querying

	left : INTEGER;
	top : INTEGER;
	width : INTEGER;
	height : INTEGER;

	right : INTEGER is
		do
			Result := left + width;
		end;

	bottom : INTEGER is
		do
			Result := top + height;
		end;

	is_within(other : BOUNDING_BOX) : BOOLEAN is
		do
			Result := left >= other.left
						and then right <= other.right
						and then top >= other.top
						and then bottom <= other.bottom;
		end;

	contains (x : INTEGER; y : INTEGER) : BOOLEAN is
		do
			Result := (x >= left) and then (x <= right)
					  and then (y >= top) and then (y <= bottom);
		end;

	midpoint_x : INTEGER is 
		do 
			Result := (left + width/2).rounded;
		end;

	midpoint_y : INTEGER is
		do
			Result := (top + height/2).rounded;
		end;

	intersection_with_line (line : LINE_SEGMENT) : POINT is
			-- Find the point where this bounding box intersects the
			-- LINE_SEGMENT line.  Give Void if it doesn't.
		local
			tmp : LINE_SEGMENT;
		do
								-- Try left side
			!!tmp.make(left, top, left, bottom);
			Result := line.intersection_point(tmp);
			if Result = Void then
								-- Try the top side
				tmp.set_coordinates(left, top, right, top);
				Result := line.intersection_point(tmp);
				if Result = Void then
								-- Try the right side
					tmp.set_coordinates(right, top, right, bottom);
					Result := line.intersection_point(tmp);
					if Result = Void then
								-- Try the bottom side
						tmp.set_coordinates(left, bottom, right, bottom);
						Result := line.intersection_point(tmp);
					end
				end
			end
		end;




feature		-- Modification

	set_to_point(x : INTEGER; y : INTEGER) is
		-- Set the bounding box to the single point (x, y)
		do
			left := x;
			top := y;
			width := 0;
			height := 0;
		end;

	expand_to_include(x : INTEGER; y : INTEGER) is
		-- Make the bounding box include x and y
		local
			x_min : INTEGER;
			x_max : INTEGER;
			y_min : INTEGER;
			y_max : INTEGER;
		do
			x_min := left;
			y_min := top;
			x_max := right;
			y_max := bottom;

			if (x < x_min) then
				x_min := x;
			elseif (x > x_max) then
				x_max := x;
			end;
			if (y < y_min) then
				y_min := y;
			elseif (y > y_max) then
				y_max := y;
			end;

			left := x_min;
			top := y_min;
			width := x_max - x_min;
			height := y_max - y_min;
		end;

	expand_to_include_box (other : BOUNDING_BOX) is
		do
			expand_to_include(other.left, other.top);
			expand_to_include(other.right, other.bottom);
		end;

	set_left(x : INTEGER) is
			-- Change the left side without changing width
		do
			left := x;
		end;

	set_right(x : INTEGER) is
			-- Change the right side without changing width
		do
			left := x - width;
		end;


	set_top(y : INTEGER) is
			-- Change the top without changing height
		do
			top := y;
		end;

	set_bottom(y : INTEGER) is
			-- Change the bottom without changing height
		do
			top := y - height;
		end;

	set_height(h : INTEGER) is
			-- Change the height, leaving top constant
		do
			height := h;
		end;

	set_width(w : INTEGER) is
			-- Change the width, leaving left constant
		do
			width := w;
		end;



end -- class BOUNDING_BOX
