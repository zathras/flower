deferred class DRAW_MANHATTAN_CONNECTION_CMD
	-- Handles a series of mouse left button clicks for a CONTROLLER that
	-- are tracing the lines of some kind of relationship that is drawn as
	-- a manhattan connection.

inherit

	DIAGRAM_BUTTON_DOWN_CMD
		redefine
			mouse_down, mouse_move, cancel
		end;

feature		-- Initialize/Release

	make (c : CONTROLLER) is
		do
			controller := c;
			!!spans.make(0);
		end;

feature		-- Actions

	mouse_down(x : INTEGER; y : INTEGER) is
		do
			if start_class = Void then
				start_class ?= controller.find_drawable(x, y);
				if start_class /= Void then
					show_hint(drawing_hint);
				end;
			elseif current_span /= Void then
				end_class ?= controller.find_drawable(x, y);
				if end_class /= Void then
					finish_command;
				else
					add_chained_span(x, y);
				end;
			end;
		end;

	mouse_move (x : INTEGER; y : INTEGER) is
		do
			if current_span = Void then
				if start_class /= Void and then not start_class.contains(x, y)
				then
					current_span := start_class.make_best_manhattan_span(x, y);
				end;
			else
				current_span.move_destination(x, y);
				if current_span.constraint_violated then
					current_span.release;
					current_span := Void;
					if not start_class.contains(x, y) then
						current_span 
							:= start_class.make_best_manhattan_span(x, y);
					end;
				end
			end;
		end;

feature	--  Requests

	display_user_hint is
		do
			show_hint(starting_hint);
			set_cursor("hand2");
		end;


	cancel is
		local
			i : INTEGER;
		do
			show_hint("");
			set_cursor("");
			controller.tk_app.bell;
			if current_span /= Void then
				current_span.release;
				current_span := Void;
			end;
			from i := 1 until i > spans.count loop
				(spans @ i).release;
				i := i + 1;
			end;
			spans.wipe_out;
			controller.end_button_down_cmd;
		end;

	undo_one_step is
		local
			x, y : INTEGER;
		do
			if current_span = Void then
				cancel;
			else
				x := current_span.destination.x;
				y := current_span.destination.y;
				remove_last_span;
				if current_span /= Void then
					current_span.move_destination(x, y);
				else
					cancel;
				end;
			end;
		end;

feature { DRAW_MANHATTAN_CONNECTION_CMD } 	-- Subclass Responsability

	create_relationship (src, dest : LOGICAL_MODEL_ITEM) : LM_RELATIONSHIP is
			-- Deliver a new instance of the kind of relationship that
			-- this connection represents.
		deferred
		end;

	drawing_hint : STRING is
		-- Give a message to display while drawing the connection.  Provided
		-- is a reasonable default.
		do
			Result := "Left click on other class, or intermediate point";
		end;

	starting_hint : STRING is
		-- Give a message to display at the beginning of the operation
		do
			Result := "Left-click at the source of the relationship";
		end;

feature { NONE }		-- Private

	controller : CONTROLLER;

	show_hint(s : STRING) is
		do
			controller.diagram.show_hint(s);
		end;


	set_cursor (s : STRING) is
		do
			controller.diagram.set_cursor(s);
		end;

	start_class : CLASS_BOX;
	end_class : CLASS_BOX;

	current_span : MANHATTAN_SPAN; 
				-- The span currently being dragged around
	spans : ARRAYED_LIST[MANHATTAN_SPAN];	
				-- The spans we've created so far (not including current_span)

	connection_start : SOLID is
		-- The drawable where the connection starts
		do
			Result := start_class;
		end

	connection_end : SOLID is
		-- The drawable where the connection ends
		do
			Result := end_class;
		end


	add_chained_span(x : INTEGER; y : INTEGER) is
			-- Chain another span onto current connection, starting at (x,y)
		local
			source : SPAN_ENDPOINT;
			destination : SPAN_ENDPOINT;
			source_side_vertical : BOOLEAN;
			constraint : ENDPOINT_CONSTRAINT;
		do
			current_span.move_destination(x, y);
			current_span.destination.fix_in_place;
			source := current_span.destination;
			source_side_vertical 
				:= current_span.destination_line_is_horizontal;
			spans.extend(current_span);
			!!destination.make(x, y);
			!!current_span.make(source, destination,
							    controller.diagram.canvas, 
							    source_side_vertical);
		end;

	remove_last_span is
		require
			span_in_progress: current_span /= Void;
		do
			current_span.release;
			current_span := Void;
			if spans.count > 0 then
				current_span := spans @ spans.count;
				current_span.destination.set_constraint(Void);
				spans.go_i_th(spans.count);
				spans.remove;
			end;
		end;

	finish_command is
			-- Finish this command by terminating the association at
			-- a class.
		require
			end_seen: end_class /= Void;
			span_in_progress: current_span /= Void;
		local
			line : LINE_SEGMENT;
			sol : SOLID;
			new_endpoint : SPAN_ENDPOINT;
			relationship : LM_RELATIONSHIP;
			connection : CONNECTION;
		do
			!!line.make_uninitialized;
			sol := end_class;
			from until new_endpoint /= Void or else current_span = void 
			loop
				line.set_coordinates(current_span.midpoint_x, 
							         current_span.midpoint_y,
							         current_span.destination.x,
							         current_span.destination.y);
				new_endpoint := sol.endpoint_intersection_with_line(line);
				if new_endpoint = Void then
					-- Try the first part of the span
					line.set_coordinates(current_span.midpoint_x, 
									     current_span.midpoint_y,
									     current_span.source.x,
									     current_span.source.y);
					new_endpoint := sol.endpoint_intersection_with_line(line);
				end;
				if new_endpoint = Void then
					remove_last_span;
				end;
			end;
			if new_endpoint = Void then
				cancel
			else
				current_span.set_destination_endpoint(new_endpoint);
				show_hint("");
				set_cursor("");
				controller.end_button_down_cmd;

				spans.extend(current_span);
				remove_intermediate_endpoint_constraints;
				relationship 
					:= create_relationship(start_class.logical_model_item,
										   end_class.logical_model_item);
				controller.diagram.app.logical_model.items.extend(relationship);
				!MANHATTAN_CONNECTION!connection
					.make(relationship, controller.diagram, 
						  connection_start, connection_end, spans);
				spans := Void;	-- connection owns it now
			end;
		end;


	remove_intermediate_endpoint_constraints is
			-- Remove the constraints fixing intermediate endpoints in place.
			-- These constraints were useful while tracing the lines, but
			-- just get in the way during movement.
		local
			i : INTEGER;
		do
			from i := 2 until i > spans.count loop
				(spans @ i).source.set_constraint(Void);
				i := i + 1;
			end;
		end;

end -- class DRAW_ASSOCIATION_CMD
