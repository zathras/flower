class SPAN_ENDPOINT 
	-- Represents the endpoint of a span.  Endpoints have constraints that
	-- dictate how they can move, and that further constrain spans emanating
	-- from them.


inherit

	PROJECT_STREAMABLE
		redefine
			make_for_reader,
			write_for_writer
		end;


creation

	make, 
	make_constrained,
	make_for_reader

feature		-- Initialize/Release


	make (an_x, a_y : INTEGER) is
		do
			x := an_x;
			y := a_y;
		end;

	make_constrained(an_x, a_y : INTEGER; a_constraint : ENDPOINT_CONSTRAINT) is
		do
			constraint := a_constraint;
			move_toward(an_x, a_y);
		end;



feature		-- Attributes

	x : INTEGER;		-- Current screen position
	y : INTEGER;

	constraint : ENDPOINT_CONSTRAINT;

	decoration : CONNECTION_DECORATION;
					-- The decoration on the span eminating from this
					-- endpoint, if any.


feature		-- Modification

	set_constraint(a_constraint : ENDPOINT_CONSTRAINT) is
		do
			constraint := a_constraint
			move_toward(x, y);
		end;

	set_decoration (d : CONNECTION_DECORATION) is
		do
			decoration := d;
		end;

	fix_in_place is
		-- Nail this endpoint down at its current position by setting
		-- the constraint to something appropriate
		do
			!ENDPOINT_FIXED_CONSTRAINT!constraint.make(x, y);
		end

	move_toward (an_x : INTEGER; a_y : INTEGER) is
			-- Move the point toward (an_x, a_y) respecting the
			-- endpoint constraints
		do
			x := an_x.max(min_x);
			x := x.min(max_x);
			y := a_y.max(min_y);
			y := y.min(max_y);
		ensure
			within_constraints: not point_violates_constraints
		end;


feature		-- Query

	coincides_with (other : SPAN_ENDPOINT) : BOOLEAN is
		-- Is this point at the same position as other?
		do
			Result := x = other.x and then y = other.y;
		end;

	point_violates_constraints : BOOLEAN is
			-- Is our x,y value within the constraints 
		do
			Result := x < min_x
					  or else x > max_x
					  or else y < min_y
					  or else y > max_y
		end;

	span_violates_constraints (a_span : SPAN) : BOOLEAN is
			-- Does the span a_span violate any span constraints
			-- attached to this endpoint?
		require
			connected_to_us: a_span.source = Current 
							 or else a_span.destination = Current
		do
			if constraint = Void then
				Result := false
			else
				Result := constraint.span_violates_constraints(a_span);
			end
		end;

	requires_vertical_spans : BOOLEAN is
		do
			if constraint = Void then
				Result := false
			else
				Result := constraint.requires_vertical_spans
			end
		end;

	requires_horizontal_spans : BOOLEAN is
		do
			if constraint = Void then
				Result := false
			else
				Result := constraint.requires_horizontal_spans
			end
		end;

	is_constrained_to (a_solid : SOLID) : BOOLEAN is
			-- Is this endpoint constrained to move with a_solid?
		do
			Result := constraint /= Void
					 and then constraint.constrains_point_to(a_solid);
		end;

	attached_solid : SOLID is
			-- Gives the solid to which this endpoint is constrained, or
			-- Void if it isn't constrained to one.
		do
			if constraint = Void then
				Result := Void
			else
				Result := constraint.constraining_solid		-- Might be Void
			end;
		end;

	pos_after_decoration : POINT is
			-- The position where a span eminating from this endpoint
			-- should really start
		do
			if decoration = Void then
				!!Result.make(x, y);
			else
				Result := decoration.span_start;
			end -- if
		end;


feature { CONNECTION }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		local
			id : INTEGER;
		do
			writer.left_paren;
			writer.write_token("span-endpoint");
			id := writer.set_span_endpoint_id(Current);
			writer.write_integer(id);
			writer.write_integer(x);
			writer.write_integer(y);
			if constraint = Void then
				writer.write_token("nil");
			else
				constraint.write_for_writer(writer);
			end
			writer.right_paren;
			writer.new_line;
		end;

feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			id_str : STRING;
			x_str, y_str, cons_type_str, solid_str : STRING;
			a_constraint : ENDPOINT_CONSTRAINT;
		do
			if args.count < 4 or else args.count > 5 then
				reader.error("Incorrect number of arguments to span-endpoint");
			end;
			id_str ?= args @ 1;
			x_str ?= args @ 2;
			y_str ?= args @ 3;
			cons_type_str ?= args @ 4;
			if args.count > 4 then
				solid_str ?= args @ 5;
			end;
			if x_str = Void or else y_str = Void
			   or else not x_str.is_integer or else not y_str.is_integer
			   or else cons_type_str = Void 
		    then
				reader.error("Argument error in span-endpoint")
			end
			x := x_str.to_integer;
			y := y_str.to_integer;
			constraint 
				:= reader.make_endpoint_constraint(cons_type_str, 
												   solid_str, x, y);
			reader.add_span_endpoint (id_str, Current);
		end;

feature { NONE }

	min_x : INTEGER is
		do
			if constraint = Void then
				Result := -infinity
			else
				Result := constraint.min_x
			end
		end;

	max_x : INTEGER is
		do
			if constraint = Void then
				Result := infinity
			else
				Result := constraint.max_x
			end
		end;

	min_y : INTEGER is
		do
			if constraint = Void then
				Result := -infinity
			else
				Result := constraint.min_y
			end
		end;

	max_y : INTEGER is
		do
			if constraint = Void then
				Result := infinity
			else
				Result := constraint.max_y
			end
		end;


	infinity : INTEGER is 100000000;
		-- Comfortably less than 2^31, but big enough so that canvases will
		-- never be as big.  I might have used 2^31-1, but I couldn't find
		-- a maxint constant defined anywhere (and besides, who says integers
		-- will *necessarily* have a maximum value forever?)



end -- class SPAN_ENDPOINT
