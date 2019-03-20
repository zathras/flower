deferred class DIAGRAM_DRAG 
	-- Represents any drag operation in a DIAGRAM.


feature		-- Actions

	mouse_move(new_x : INTEGER; new_y : INTEGER) is
		deferred
		end;

	mouse_up(new_x : INTEGER; new_y : INTEGER) is
		deferred
		end;



end -- class DIAGRAM_DRAG
