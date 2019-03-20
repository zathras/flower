
#
# This file contains utilities that are depended on in the TK_APPLICATION
# and TCL_INTERPRETER classes.
#



#
#  Utilitiy needed from TCL_INTERPRETER:  Set the value of a member of a global
#  array.
#
proc set_global_array {array member value} {
    global [set array]
    set [set array]($member) $value
}


#
#  Utilitiy needed from TCL_INTERPRETER:  Get the value of a member of a global
#  array.
#
proc get_global_array {array member} {
    global [set array]
    return [set [set array]($member)]
}

# Utility needed from TK_APPLICATION:  prompt for a value.  This was 
# stolen from Brent Welch's book.

proc GetValue { string } {
	global prompt
	set prompt(result) ""
	set f [toplevel .prompt -borderwidth 10]
	message $f.msg -text $string -aspect 500
	entry $f.entry -textvariable prompt(result)
	set b [frame $f.buttons -bd 10]
	pack $f.msg -padx 20 -side top -fill x
	pack $f.entry $f.buttons -side top -fill x
	
	button $b.ok -text OK -command {set prompt(ok) 1} \
		-underline 0
	button $b.cancel -text Cancel -command {set prompt(ok) 0} \
		-underline 0
	pack $b.ok -side left
	pack $b.cancel -side right

	foreach w [list $f.entry $b.ok $b.cancel] {
	    bindtags $w [list .prompt [winfo class $w] $w all]
	}
	bind .prompt <Alt-o> "focus $b.ok ; break"
	bind .prompt <Alt-c> "focus $b.cancel ; break"
	bind .prompt <Alt-Key> break
	bind .prompt <Return> {set prompt(ok) 1}
	bind .prompt <Control-c> {set prompt(ok) 0}

	focus $f.entry
	grab $f
	tkwait variable prompt(ok)
	grab release $f
	destroy $f
	if {$prompt(ok)} {
		return $prompt(result)
	} else {
		return {}
	}
}

# Utility needed from TK_APPLICATION:  show a message.  This was adapted 
# from GetValue :-)

proc ShowMessage { string } {
	set isDone 0
	set f [toplevel .showmsg -borderwidth 10]
	message $f.msg -text $string -aspect 500
	set b [frame $f.buttons -bd 10]
	pack $f.msg -padx 20 -side top -fill x
	pack $f.buttons -side top -fill x
	
	button $b.ok -text OK -command {set isDone 1} \
		-underline 0
	pack $b.ok -side left -expand true

	foreach w [list $b.ok] {
	    bindtags $w [list .showmsg [winfo class $w] $w all]
	}
	bind .showmsg <Alt-o> "focus $b.ok ; break"
	bind .showmsg <Alt-Key> break

	focus $b.ok
	grab $f
	tkwait variable isDone
	grab release $f
	destroy $f
}

