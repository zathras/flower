class CONTROLLER 

	-- Controls a diagram.  Input events (mouse and keyboard) are sent to
	-- the controller, and it takes appropriate actions on the diagram.

creation

	make

feature		-- Initialize/Release

	make (a_diagram : DIAGRAM) is
		local
			command : TCL_COMMAND;
		do
			diagram := a_diagram;
		end;


feature		-- Services


	find_drawable (x : INTEGER; y : INTEGER) : DRAWABLE is
		local
			i : INTEGER;
		do
			from 
				Result := void;
				i := 1;
			until
				Result /= Void or else i > diagram.drawables.count
			loop
				if (diagram.drawables @ i).contains(x, y) then
					Result := diagram.drawables @ i;
				end;
				i := i + 1;
			end;
		end;


feature { TCL_COMMAND, DIAGRAM_DRAG, DIAGRAM_BUTTON_DOWN_CMD }		-- Collaborators

	diagram : DIAGRAM;

	tk_app : TK_APPLICATION is
		do
			Result := diagram.tk_app;
		end;

feature { TCL_COMMAND }		-- Actions

	button_1_down(x : INTEGER; y : INTEGER) is
		local
			d : DRAWABLE;
		do
			if current_button_down_cmd /= Void then
				current_button_down_cmd.mouse_down(x, y);
			else
				d := find_drawable(x, y);
				if d /= Void then
				    if d.selected then
						d.single_select(x, y);
							-- In case some other part of the drawable is
							-- now selected (as with a CONNECTION)
				    else
						diagram.single_select_drawable(d, x, y);
					end  -- if
				end -- if
				if d /= Void then
					!DIAGRAM_ITEM_MOVE_START!current_drag.make(Current, x, y);
				else
					!DIAGRAM_LASSO!current_drag.make(Current, x, y);
					diagram.deselect_all;
				end
			end
		end;

	button_1_double(x : INTEGER; y : INTEGER) is
			-- Receive a mouse button 1 double click
		local
			d : DRAWABLE;
			item : LOGICAL_MODEL_ITEM;
		do
			if current_button_down_cmd /= Void then
				current_button_down_cmd.cancel;
				end_button_down_cmd;
			end
			d := find_drawable(x, y);
			if d /= Void then
				item := d.logical_model_item;
			end -- if
			if item = Void or else (not item.can_be_edited) then
				tk_app.bell;
			else 
				diagram.single_select_drawable(d, x, y);
						-- Make sure it's the only thing selected
				item.launch_editor;
			end -- if
		end;

	button_1_up(x : INTEGER; y : INTEGER) is
		do
			if current_drag /= Void then
				current_drag.mouse_up(x, y);
			end;
		end;

	button_3_down(x : INTEGER; y : INTEGER) is
		do
			if current_button_down_cmd /= Void then
				current_button_down_cmd.undo_one_step;
			end;
		end;


	mouse_move(x : INTEGER; y : INTEGER) is
		do
			if current_drag /= Void then
				current_drag.mouse_move(x, y);
			elseif current_button_down_cmd /= Void then
				current_button_down_cmd.mouse_move(x, y);
			end;
		end;

	set_button_down_cmd ( c : DIAGRAM_BUTTON_DOWN_CMD ) is
		do
			if current_button_down_cmd /= Void then
				current_button_down_cmd.cancel;
			end;
			current_button_down_cmd := c;
			c.display_user_hint;
		end;


feature { DIAGRAM_BUTTON_DOWN_CMD }	-- Button down command interface

	end_button_down_cmd is
		do
			current_button_down_cmd := Void;
		end;


feature { DIAGRAM_DRAG }	-- Interface to drag operations

	start_item_drag(start_x : INTEGER; start_y : INTEGER;
				    curr_x : INTEGER; curr_y : INTEGER) is
		do
			if diagram.selected.count = 1
				and then (diagram.selected @ 1).supports_direct_drag
			then
				!DIAGRAM_ITEM_MOVE_DIRECT!current_drag.make
						(Current, start_x, start_y, diagram.selected @ 1);
			else
				!DIAGRAM_ITEM_MOVE!current_drag.make(Current, start_x, start_y);
			end; -- if
			current_drag.mouse_move(curr_x, curr_y);
		end;

	cancel_current_drag is
		do
			current_drag := Void;
		end;

	current_drag : DIAGRAM_DRAG;	-- Drag operation currently in progress

feature { CONTROLLER }		-- Protected


	current_button_down_cmd : DIAGRAM_BUTTON_DOWN_CMD;

end -- class CONTROLLER
