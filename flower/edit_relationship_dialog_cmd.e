deferred class EDIT_RELATIONSHIP_DIALOG_CMD 
	-- Abstract superclass of commands attached to the EDIT_CLASS_DIALOG

inherit

	TCL_COMMAND

feature		-- Initialize/Release

	make (a_dialog : EDIT_RELATIONSHIP_DIALOG) is
		do
			dialog := a_dialog
		end;

feature	{ EDIT_RELATIONSHIP_DIALOG_CMD }	-- Subclass implementation

	dialog : EDIT_RELATIONSHIP_DIALOG;


end -- class EDIT_RELATIONSHIP_DIALOG_CMD
