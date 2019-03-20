class POINT 
	-- Represents the abstract idea of a 2D point with integral coordinates.

creation

	make

feature		-- Initialize/Release

	make (an_x : INTEGER; a_y : INTEGER) is
		do
			x := an_x;
			y := a_y;
		end;

feature		-- Attributes

	x : INTEGER;
	y : INTEGER;

feature		-- Modification

	set_x (an_x : INTEGER) is
		do
			x := an_x;
		end;

	set_y (a_y : INTEGER) is
		do
			y := a_y;
		end;

end -- class POINT
