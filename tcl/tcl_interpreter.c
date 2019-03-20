/*		tcl_interpreter.c

	C side fo tcl_interpreter.e

*/



#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include <tcl.h>
#include <eiffel.h>


/* Annoying C routines that are only necessary because Eiffel converts
   upper-case in C identifiers to lower-case.  Sigh.
*/


void* c_tcl_createinterp()

{
    return Tcl_CreateInterp();
}

void c_tcl_deleteinterp(void* interp)

{
    Tcl_DeleteInterp(interp);
}

/*  Real C routines: */


int c_command_callback(EIF_POINTER instance, Tcl_Interp* interp,
		       int argc, char*argv[]);

void c_create_eiffel_command(EIF_OBJ instance, void* interp)

{
    instance = eif_adopt(instance);
    Tcl_CreateCommand(interp, "eiffel", (void*) c_command_callback, 
    		      instance, NULL);
}


void c_release_eiffel_interpreter(EIF_OBJ instance)

{
    eif_wean(instance);
}



EIF_POINTER c_eval(Tcl_Interp* interp, const char* command, EIF_OBJ result)

{
    /* An evil fact of Tcl_Eval is that it might change the contents
       of the string that one sends it.  For this reason, we make a copy.
       @@ Someday, put some of this in a static buffer

       An evil fact of Eiffel is that it can't handle extern function returning
       BOOLEAN (it gives a type mismatch in the C compile), so we take the
       hokey step of returning NULL or something else to indicate error.
   */

    char* my_copy;
    int ok;
    static int first = 1;
    static EIF_TYPE_ID	  string_type;
    static EIF_PROC	  string_from_c;

    if (first)  {
    	first = 0;
        string_type = eif_type_id("STRING");
        string_from_c = eif_proc("from_c", string_type);
    }

    my_copy = strdup(command);
    ok = Tcl_Eval((void*) interp, my_copy) == TCL_OK;
    (*string_from_c)(eif_access(result), interp->result);
    free(my_copy);
    return ok ? NULL : "error";
}


EIF_POINTER c_evalfile(Tcl_Interp* interp, char* file_name, EIF_OBJ result)

{
    /* Like c_eval */
    int ok;
    static int first = 1;
    static EIF_TYPE_ID	  string_type;
    static EIF_PROC	  string_from_c;

    if (first)  {
    	first = 0;
        string_type = eif_type_id("STRING");
        string_from_c = eif_proc("from_c", string_type);
    }

    ok = Tcl_EvalFile((void*) interp, file_name) == TCL_OK;
    (*string_from_c)(eif_access(result), interp->result);
    return ok ? NULL : "error";
}


const char* c_access_string_array(char* argv[], int i)

{
    return argv[i];
}

void c_tcl_set_result(Tcl_Interp* interp, const char* str)

{
    Tcl_SetResult(interp, strdup(str), TCL_DYNAMIC);
}

int c_command_callback(EIF_POINTER instance, Tcl_Interp* interp,
		       int argc, char*argv[])

{
    static int first = 1;
    static EIF_TYPE_ID	  tcl_interpreter_type;
    static EIF_FN_BOOL    command_callback;
    int		ok;

    if (first)  {
    	first = 0;
	tcl_interpreter_type = eif_type_id("TCL_INTERPRETER");
	command_callback 
	    = eif_fn_bool("command_callback", tcl_interpreter_type);
    }

    ok = (*command_callback)(eif_access(instance), interp, argc-1, argv+1);
	/* We don't pass the "eiffel" that triggered the command */

    return ok ? TCL_OK : TCL_ERROR;
}


void* c_null_pointer()

{
    return NULL;
}

