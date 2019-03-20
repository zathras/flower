#!/usr/local/bin/wish
#	^^ That line is just for testing the UI under a wish...  It has
#	   no meaning in the real application.
#
#  Flower tcl script
#
#  This script contains all of the tcl definitions used in the flower
#  CASE tool.  See README for more details.
#
#

set FlowerVersion "0.1 (prototype)"

# Procedure to open a rumbaugh class diagram:

proc openRumbaughClass {} {
    # Use a combobox here, given a list of existing diagrams...
    set name [GetValue "Enter the name of the class diagram:"]
    if {$name != ""} {
    	eiffel open_rumbaugh_class "$name"
    	#@@ Check to see if it is already open, and if so just
    	#   pop it to the top of the window stack.
    }
}

# Procedure to create the main menu:


proc createMainScreen { } {
    global FlowerVersion
    wm title . [concat "Flower " $FlowerVersion]
    frame .mm -borderwidth 4
    pack .mm -side top -fill x
    menubutton .mm.fileMenu -text File -menu .mm.fileMenu.menu -underline 0
    pack .mm.fileMenu -side left
    set m [menu .mm.fileMenu.menu -tearoff 0]
    $m add command -label "Open..." -underline 0 -command {open_project}
    $m add command -label "Save as..." -underline 5 -command {save_as}
    $m add command -label "About..." -underline 0 -command {show_about}
    $m add command -label Exit -underline 1 -command {eiffel exit}
    menubutton .mm.rumbaughMenu -text Rumbaugh -menu .mm.rumbaughMenu.menu \
    	-underline 0
    set m [menu .mm.rumbaughMenu.menu -tearoff 1]
    $m add command -label "Object Diagram..." -underline 0 \
    	-command {openRumbaughClass}
    pack .mm.rumbaughMenu -side left -expand true

    frame .acc1 -bd 2 -relief raised 
    # Frame for accelerator buttons
    button .acc1.rumObjOpen -background white -bitmap @bitmaps/rum_class.xbm \
    		-command {openRumbaughClass}
    pack .acc1.rumObjOpen -side left
    pack .acc1 -side top -padx 10 -fill x 

    frame .bottom
    pack .bottom -side top -pady 5 -expand true
}

# Main menu "save_as" command:

proc save_as {} {
    set name [GetValue "Save project in file:"]
    if {$name != ""} {
	eiffel save_project $name
    }
}


# Main menu "show_about" command

proc show_about {} {
    global FlowerVersion
    set msg "Flower version "
    append msg $FlowerVersion
    append msg "\n\n"
    append msg "by Bill Foote\n"
    append msg "billf@jovial.com\n"
    append msg "http://www.jovial.com/~billf/\n\n"
    append msg "All rights reserved"
    ShowMessage $msg
}

proc open_project {} {
	# @@ We should ask before wiping out existing project
    set name [GetValue "Load project from file:"]
    if {$name != ""} {
	eiffel open_project $name
    }
}


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


#
#  Prompt for the name of a new class to create, then create it
#

proc prompt_create_class { diagram_id } {
    set name [GetValue "Create a class named:"]
    if {$name != ""} {
	eiffel create_class $diagram_id $name
    }
}

#
#  Make a class diagram.  Returns the name of the dialog.  The canvas
#  will be at <dialog_name>.canvas, and a hint label will be at
#  <dialog_name>.hint.
#

proc make_class_diagram { paradigm id title } {
    set name "."
    append name $paradigm
    append name "_"
    append name $id
    toplevel $name
    wm title $name $title

    frame $name.mm -borderwidth 4
    pack $name.mm -side top -fill x
    menubutton $name.mm.fileMenu -text File -menu $name.mm.fileMenu.menu \
    	-underline 0
    pack $name.mm.fileMenu -side left
    set m [menu $name.mm.fileMenu.menu -tearoff 0]
    $m add command -label close -underline 0 -command {puts "@@ not implemented"}
    menubutton $name.mm.createMenu -text Create \
    	-menu $name.mm.createMenu.menu -underline 0
    set m [menu $name.mm.createMenu.menu -tearoff 1]
    $m add command -label "Class" -underline 0 \
    	-command [list prompt_create_class $id ]
    $m add command -label "Association" -underline 0 \
    	-command [list eiffel create_association $id ]
    $m add command -label "Aggregation" -underline 1 \
    	-command [list eiffel create_aggregation $id ]
    $m add command -label "Specialization" -underline 0 \
    	-command [list eiffel create_specialization $id ]
    pack $name.mm.createMenu -side left

    # Hint label:

    label $name.hint -text "" -anchor nw
    pack $name.hint -in $name -padx 15 -side bottom -fill x 

    # Make the canvas:

    frame $name.f -bd 3 -relief sunken
    canvas $name.canvas -width 400 -height 500 \
    	-scrollregion {0 0 900 1200} \
    	-xscrollcommand [list $name.f.xscroll set] \
    	-yscrollcommand [list $name.f.yscroll set]
    scrollbar $name.f.xscroll -orient horizontal \
	    -command [list $name.canvas xview]
    scrollbar $name.f.yscroll -orient vertical \
	    -command [list $name.canvas yview]
    pack $name.f.xscroll -side bottom -fill x
    pack $name.f.yscroll -side right -fill y
    pack $name.canvas -in $name.f -side top -fill both -expand true

    # Add Eiffel event bindings to canvas

    bind $name.canvas <Motion> [ concat eiffel diagram_mouse_motion $id \
    		\[ $name.canvas canvasx %x \] \[ $name.canvas canvasy %y \] ]
    bind $name.canvas <ButtonPress-1> [ concat eiffel diagram_mouse_1_down $id \
    		\[ $name.canvas canvasx %x \] \[ $name.canvas canvasy %y \] ]
    bind $name.canvas <Double--1> [ concat eiffel diagram_mouse_1_double $id \
    		\[ $name.canvas canvasx %x \] \[ $name.canvas canvasy %y \] ]
    bind $name.canvas <ButtonRelease-1> [ concat eiffel diagram_mouse_1_up $id \
    		\[ $name.canvas canvasx %x \] \[ $name.canvas canvasy %y \] ]
    bind $name.canvas <ButtonPress-3> [ concat eiffel diagram_mouse_3_down $id \
    		\[ $name.canvas canvasx %x \] \[ $name.canvas canvasy %y \] ]

    pack $name.f -side top -fill both -expand true

    return $name
}

#		edit_class
#
# creates or shows a dialog to use for editing classes.  Returns the
# global name by which this dialog and its attributes are known
# (hereinafter referred to as $name).  Only one such dialog may be open 
# at a time, so the Eiffel class that encapsulates this 
# (MODIFY_CLASS_DIALOG) should be a singleton.
#
# Generates commands:
#
#	ecd_apply $name			(apply changes)
#	ecd_close $name			(close dialog)
#	ecd_method_select $name #	(Select method #, counting from 0)
#	ecd_variable_select $name #	(Select variable #, counting from 0)
#	ecd_member_apply $name 		(Apply changes to selected member)
#	ecd_member_delete $name		(delete selected member)
#	ecd_delete_class $name		(delete the class being edited)
#
# The following widgets/global variables are of interest:
#
#	.$name.l.methods.list	The listbox of methods
#	.$name.l.variables.list	The listbox of variables
#	$name(class_name)	The string for the class name
#	$name(member_name)	The string for the member name
#	$name(member_type)	The string for the member type

proc edit_class { class_name methods variables } {
    set name "edit_class"
    global [set name]
    set [set name](class_name) $class_name
    set [set name](member_name) ""
    set [set name](member_type) ""
    if { [ info command .$name ] == "" } {
	toplevel .$name -height 300 -width 400
	frame .$name.nm -borderwidth 4
	pack .$name.nm -side top -fill x
	label .$name.nm.lbl -text "Class name:"
	pack .$name.nm.lbl -side left
	entry .$name.nm.msg -textvariable [set name](class_name)
	pack .$name.nm.msg -side left -padx 20 -fill x -expand true
	button .$name.nm.delete -text "Delete Class" \
		-command [list eiffel ecd_delete_class $name]
	pack .$name.nm.delete -side left -padx 20

	frame .$name.b
	pack .$name.b -side bottom -pady 10 -padx 10 -fill x
	frame .$name.b.blank1
	pack .$name.b.blank1 -side left -fill x -expand true
	button .$name.b.ok -text "OK"  \
		-command [list edit_class_do_ok_button $name]
	pack .$name.b.ok -side left
	frame .$name.b.blank2
	pack .$name.b.blank2 -side left -fill x -expand true
	button .$name.b.accept -text "Apply"  \
		-command [list eiffel ecd_apply $name]
	pack .$name.b.accept -side left
	frame .$name.b.blank3
	pack .$name.b.blank3 -side left -fill x -expand true
	button .$name.b.close -text "Close" \
		-command [list eiffel ecd_close $name]
	pack .$name.b.close -side left
	frame .$name.b.blank4
	pack .$name.b.blank4 -side left -fill x -expand true

	frame .$name.l -borderwidth 3 -relief groove
	pack .$name.l -fill both -padx 2 -expand true

	frame .$name.mem -borderwidth 2 -relief sunken
	pack .$name.mem -in .$name.l -padx 10 -pady 10 -fill x -side bottom
	frame .$name.mem.lbl
	pack .$name.mem.lbl -side left -pady 4
	label .$name.mem.lbl.name -anchor ne -text "Member name:"
	pack .$name.mem.lbl.name -side top -fill x -padx 8
	label .$name.mem.lbl.type -anchor ne -text "type:"
	pack .$name.mem.lbl.type -side top -fill x -padx 8
	frame .$name.mem.ent
	pack .$name.mem.ent -side left -fill x -expand true -pady 4
	entry .$name.mem.ent.name -textvariable [set name](member_name)
	pack .$name.mem.ent.name -side top -fill x -expand true
	entry .$name.mem.ent.type -textvariable [set name](member_type)
	pack .$name.mem.ent.type -side top -fill x -expand true
	frame .$name.mem.b
	pack .$name.mem.b -side left
	button .$name.mem.b.accept -text "Apply" \
		-command [list eiffel ecd_member_apply $name]
	pack .$name.mem.b.accept -side top -padx 10
	button .$name.mem.b.delete -text "Delete" \
		-command [list eiffel ecd_member_delete $name]
	pack .$name.mem.b.delete -side top -padx 10

	frame .$name.l.methods -borderwidth 4
	pack .$name.l.methods -side left -fill both -expand true
	label .$name.l.methods.lbl -anchor nw -text "Methods:"
	pack .$name.l.methods.lbl -side top -fill x -padx 4
	listbox .$name.l.methods.list -setgrid true -width 10 -height 8 \
		-yscrollcommand [list .$name.l.methods.sy set]
	bind .$name.l.methods.list <ButtonPress-1> \
	    [list edit_class_list_select $name  ecd_method_select %W %y]
	scrollbar .$name.l.methods.sy -orient vertical \
		-command [list .$name.l.methods.list yview]
	pack .$name.l.methods.sy -side right -fill y
	pack .$name.l.methods.list  -side left -fill both -expand true

	frame .$name.l.variables -borderwidth 4
	pack .$name.l.variables -side left -fill both -expand true
	label .$name.l.variables.lbl -anchor nw -text "Variables:"
	pack .$name.l.variables.lbl -fill x -padx 5 -side top
	listbox .$name.l.variables.list -setgrid true -width 10 -height 8 \
		-yscrollcommand [list .$name.l.variables.sy set]
	bind .$name.l.variables.list <ButtonPress-1> \
	    [list edit_class_list_select $name  ecd_variable_select %W %y]
	scrollbar .$name.l.variables.sy -orient vertical \
		-command [list .$name.l.variables.list yview]
	pack .$name.l.variables.sy -side right -fill y
	pack .$name.l.variables.list  -side left -fill both -expand true
    } else {
    	wm deiconify .$name
	raise .$name
    }
    set title "Edit "
    append title [set [set name](class_name)]
    append title " Class"
    wm title .$name $title

    .$name.l.methods.list delete 0 [.$name.l.methods.list size]
    .$name.l.variables.list delete 0 [.$name.l.variables.list size]
    eval {.$name.l.methods.list insert end} $methods
    eval {.$name.l.variables.list insert end} $variables
    return $name
}

#  Callback for the OK button, above
proc edit_class_do_ok_button {dialog_name} {
    eiffel ecd_apply $dialog_name
    eiffel ecd_close $dialog_name
}


#  Callback for the list boxes, above.  This resolves the y position to
#  an item number, suitable for passing to Eiffel.
proc edit_class_list_select {dialog_name eiffel_command w y} {
    eiffel $eiffel_command $dialog_name [$w nearest $y]
}


#		edit_relationship
#
# creates or shows a dialog to use for editing relationship.  Returns the
# global name by which this dialog and its attributes are known
# (hereinafter referred to as $name).  Only one such dialog may be open 
# at a time, so the Eiffel class that encapsulates this 
# (EDIT_ASSOCIATION_DIALOG) should be a singleton.
#
# Generates commands:
#
#	erelat_d_apply $name		(apply changes)
#	erelat_d_close $name		(close dialog)
#
# The following widgets/global variables are of interest:
#
#	$name(source_multiplicity)	one, optional, or many
#	$name(dest_multiplicity)	
#
#  @@ Add this command:
#	erelat_d_delete $name		(delete the relationship being edited)


proc edit_relationship { source_name has_source_attrs dest_name has_dest_attrs } {
    set name "edit_relationship"
    global [set name]
    if { [ info command .$name ] == "" } {
	toplevel .$name -height 300 -width 400

	frame .$name.contents
	pack .$name.contents -side top

	frame .$name.s -borderwidth 3 -relief groove
	pack .$name.s -side left -fill x -expand true \
		-in .$name.contents
	frame .$name.d -borderwidth 3 -relief groove
	pack .$name.d -side left -fill x -expand true \
		-in .$name.contents

	frame .$name.s.lbl -relief raised -bd 2
	pack .$name.s.lbl -side top -fill x -expand true
	label .$name.s.lbl.lbl1 -text "Source:  "
	pack .$name.s.lbl.lbl1 -side left
	label .$name.s.lbl.name -text $source_name
	pack .$name.s.lbl.name -side left

	frame .$name.d.lbl -relief raised -bd 2
	pack .$name.d.lbl -side top -fill x -expand true
	label .$name.d.lbl.lbl1 -text "Destination:  "
	pack .$name.d.lbl.lbl1 -side left
	label .$name.d.lbl.name -text $dest_name
	pack .$name.d.lbl.name -side left

	label .$name.s.title -text "Multiplicity:                         "
	pack .$name.s.title -side top
	label .$name.d.title -text "Multiplicity:                         "
	pack .$name.d.title -side top

	radiobutton .$name.s.rb1 -variable [set name](source_multiplicity) \
		-text "Exactly One" -value one -anchor nw
	pack .$name.s.rb1 -side top -expand true -fill x -padx 15
	radiobutton .$name.s.rb2 -variable [set name](source_multiplicity) \
		-text "Optional" -value optional -anchor nw
	pack .$name.s.rb2 -side top -expand true -fill x -padx 15
	radiobutton .$name.s.rb3 -variable [set name](source_multiplicity) \
		-text "Many" -value many -anchor nw
	pack .$name.s.rb3 -side top -expand true -fill x -padx 15

	radiobutton .$name.d.rb1 -variable [set name](dest_multiplicity) \
		-text "Exactly One" -value one -anchor nw
	pack .$name.d.rb1 -side top -expand true -fill x -padx 15
	radiobutton .$name.d.rb2 -variable [set name](dest_multiplicity) \
		-text "Optional" -value optional -anchor nw
	pack .$name.d.rb2 -side top -expand true -fill x -padx 15
	radiobutton .$name.d.rb3 -variable [set name](dest_multiplicity) \
		-text "Many" -value many -anchor nw
	pack .$name.d.rb3 -side top -expand true -fill x -padx 15

	frame .$name.b
	pack .$name.b -side bottom -pady 10 -padx 10 -fill x
	frame .$name.b.blank1
	pack .$name.b.blank1 -side left -fill x -expand true
	button .$name.b.ok -text "OK"  \
		-command [list edit_relationship_do_ok_button $name]
	pack .$name.b.ok -side left
	frame .$name.b.blank2
	pack .$name.b.blank2 -side left -fill x -expand true
	button .$name.b.accept -text "Apply"  \
		-command [list eiffel erelat_d_apply $name]
	pack .$name.b.accept -side left
	frame .$name.b.blank3
	pack .$name.b.blank3 -side left -fill x -expand true
	button .$name.b.close -text "Close" \
		-command [list eiffel erelat_d_close $name]
	pack .$name.b.close -side left
	frame .$name.b.blank4
	pack .$name.b.blank4 -side left -fill x -expand true
    } else {
    	wm deiconify .$name
	raise .$name
	.$name.s.lbl.name configure -text $source_name
	.$name.d.lbl.name configure -text $source_name
    }
    if { $has_source_attrs } {
	set state normal
	set fore black
    } else {
	set state disabled
	set fore grey60
	set [set name](source_multiplicity) ""
    }
    .$name.s.title configure -foreground $fore
    foreach i { rb1 rb2 rb3 } {
    	.$name.s.$i configure -state $state
    }

    if { $has_dest_attrs } {
	set state normal
	set fore black
    } else {
	set state disabled
	set fore grey60
	set [set name](dest_multiplicity) ""
    }
    .$name.d.title configure -foreground $fore
    foreach i { rb1 rb2 rb3 } {
    	.$name.d.$i configure -state $state
    }
    set title "Edit Relationship Attributes"
    wm title .$name $title

    return $name
}

#  Callback for the OK button, above
proc edit_relationship_do_ok_button {dialog_name} {
    eiffel erelat_d_apply $dialog_name
    eiffel erelat_d_close $dialog_name
}




# If we're testing from a wish, the "eiffel" command won't be defined...  We
# use this fact to stub out some things.


if { [ info command eiffel ] == "" } {
    puts "Testing flower from wish...  Many things won't work!"


    proc eiffel {command args} {
	puts "eiffel command:  $command"
	foreach arg "$args" {
	    puts "\targ:  $arg"
	}
	if {$command == "exit"} {
	    exit
	}
	if {$command == "open_rumbaugh_class"} {
	    make_class_diagram rumbaugh 1 Test
	}
    }

    edit_class "foo" {{This is} {a} {test}} {{bar} {B} {QUEUE} {in Austin}}

    edit_relationship "Source" 0 "Destination" 1
}

# Finally, we create the main screen.  This effectively launches the app.

createMainScreen



# @@:

# set w [make_class_diagram rumbaugh 1 "Test Class Diagram"]
# puts $w

