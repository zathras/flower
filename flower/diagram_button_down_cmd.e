deferred class DIAGRAM_BUTTON_DOWN_CMD
	-- Represents any operation characterized by a sequence of left
	-- mouse clicks.  The hint line of the application should
	-- be set to tell the user what to do.


feature		-- Actions

	mouse_down (x : INTEGER; y : INTEGER) is
		deferred
		end;

	mouse_move (x : INTEGER; y : INTEGER) is
		do
			-- By default, do nothing
		end;

feature		-- Requests

	display_user_hint is
			-- Display a hint for the user so that they'll know
			-- what clicking means. 
	deferred
		end;

	undo_one_step is
		deferred
		end;

	cancel is
		deferred
		end;




end -- class DIAGRAM_BUTTON_DOWN_CMD
