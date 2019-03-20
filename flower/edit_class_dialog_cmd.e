deferred class EDIT_CLASS_DIALOG_CMD inherit
	-- Abstract superclass of commands attached to the EDIT_CLASS_DIALOG

	TCL_COMMAND

feature		-- Initialize/Release

	make (a_dialog : EDIT_CLASS_DIALOG) is
		do
			dialog := a_dialog
		end;

feature	{ EDIT_CLASS_DIALOG_CMD }	-- Subclass implementation

	dialog : EDIT_CLASS_DIALOG;


end -- class EDIT_CLASS_DIALOG_CMD
