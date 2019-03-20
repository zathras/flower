class DRAW_SPECIALIZATION_CMD
	-- Handles a series of mouse left button clicks for a CONTROLLER that
	-- are tracing the lines of an association.

inherit

	DRAW_MANHATTAN_CONNECTION_CMD
		redefine
			create_relationship,
			starting_hint,
			drawing_hint,
			connection_start,
			mouse_down,
			cancel,
			remove_last_span,
			finish_command
		select
			mouse_down,
			cancel,
			remove_last_span,
			finish_command
		end;

	DRAW_MANHATTAN_CONNECTION_CMD
		rename
			mouse_down as super_mouse_down,
			cancel as super_cancel,
			remove_last_span as super_remove_last_span,
			finish_command as super_finish_command
		redefine
			create_relationship,
			starting_hint,
			drawing_hint,
			connection_start
		end;

creation

	make

feature		-- Actions

	mouse_down(x : INTEGER; y : INTEGER) is
		local
			d : DRAWABLE;
		do
			if start_class /= Void and triangle = Void then
				make_triangle(x, y);
			elseif start_class = Void then
				d := controller.find_drawable(x, y);
				triangle ?= d;
				start_class ?= d;
				if start_class /= Void then
					triangle := start_class.subclass_triangle;
				end
				if triangle /= Void then
					start_class := triangle.superclass;
					start_with_existing_triangle(x, y);
				elseif start_class /= Void then
					show_hint(drawing_hint);
				end
			else
				super_mouse_down(x, y);
			end -- if
		end;

	cancel is
		do
			if initial_span /= Void then
				initial_span.release;
				triangle.release;
			end
			super_cancel;
		end

	remove_last_span is
		do
			super_remove_last_span;
			if current_span = Void and then initial_span /= Void then
				current_span := initial_span;
				current_span.destination.set_constraint(Void);
				initial_span := Void;
				triangle.release;
				triangle := Void;
			end
		end;

	finish_command is
		local
			connection : CONNECTION;
			initial_spans : ARRAYED_LIST [ SPAN ];
		do
			if initial_span /= Void then
				!!initial_spans.make(1);
				initial_spans.extend(initial_span);
				!MANHATTAN_CONNECTION!connection
					.make(Void, controller.diagram, 
						  start_class, triangle, initial_spans);
				connection.finalize_placement;
			end -- if
			super_finish_command;
		end;


feature { DRAW_MANHATTAN_CONNECTION_CMD }	-- Superclass overrides

	create_relationship (src, dest : LOGICAL_MODEL_ITEM) : LM_RELATIONSHIP is
		do
			!LM_GENERALIZATION!Result.make(dest, src);
		end;

	starting_hint : STRING is
		do
			Result := "Left-click on the superclass, or an inheritance triangle.";
		end;

	drawing_hint : STRING is
		do
			if triangle = Void then
				Result := "Left-click where you want the triangle to be."
			else
				Result := "Left-click on the subclass."
			end
		end;

	connection_start : SOLID is
			-- Where the connection that our superclass makes should start.
		do
			Result := triangle
		end;

feature { DRAW_SPECIALIZATION_CMD } 	-- Implementation

	triangle : INHERITANCE_TRIANGLE;
		-- The inheritance triangle that's part of the representation of
		-- the specialization we're creating

	initial_span : MANHATTAN_SPAN;	
		-- The span from the source class to the inheritance triangle.  This
		-- is non-Void *only* if we created it.

	triangle_is_new : BOOLEAN is
		-- Did we create this triangle?  If not, it was already there.
		do
			Result := initial_span /= Void
		end;

	make_triangle (x, y : INTEGER) is
			-- Create the initial triangle.  Also create the first part
			-- of the span, and start the next one.
		local
			source : SPAN_ENDPOINT;
			destination : SPAN_ENDPOINT;
			source_side_vertical : BOOLEAN;
			constraint : ENDPOINT_CONSTRAINT;
		do
			!!triangle.make(x, y, start_class, controller.diagram);
			-- Chain another span onto current connection, starting at (x,y)

			current_span.move_destination(x, y);
			!ENDPOINT_TRIANGLE_TOP_CONSTRAINT!constraint.make(triangle);
			current_span.destination.set_constraint(constraint);
			initial_span := current_span;
			current_span := Void;

			!ENDPOINT_TRIANGLE_BOTTOM_CONSTRAINT!constraint.make(triangle);
			!!source.make_constrained(triangle.top_x, triangle.bottom,
									  constraint);
			source_side_vertical := False;
			!!destination.make(x, y);
			!!current_span.make(source, destination,
							    controller.diagram.canvas, 
							    source_side_vertical);
		end;

	start_with_existing_triangle(x, y : INTEGER) is
			-- Create the first span, starting with an inheritance
			-- triangle that already exists on the diagram.
		require
			triangle_set : triangle /= Void
		local
			source : SPAN_ENDPOINT;
			destination : SPAN_ENDPOINT;
			source_side_vertical : BOOLEAN;
			constraint : ENDPOINT_CONSTRAINT;
		do
			!ENDPOINT_TRIANGLE_BOTTOM_CONSTRAINT!constraint.make(triangle);
			!!source.make_constrained(triangle.top_x, triangle.bottom,
									  constraint);
			source_side_vertical := False;
			!!destination.make(x, y);
			!!current_span.make(source, destination,
							    controller.diagram.canvas, 
							    source_side_vertical);
		end;


end -- class DRAW_SPECIALIZATION_CMD
