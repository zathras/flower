/*		tk_application.c

	C side fo tk_application.e

*/



#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include <tcl.h>
#include <tk.h>
#include <eiffel.h>



void* c_tk_init(Tcl_Interp* handle)

    /* Initialize the Tk toolkit, returning the main window. */

{
    Tk_Window mainWindow;

    mainWindow = Tk_CreateMainWindow(handle, NULL, "flower", "Flower");
    if (mainWindow == NULL)  {
	fprintf(stderr, "%s\n", handle->result);
	exit(1);
    }

    if (Tcl_Init(handle) != TCL_OK)  {
	fprintf(stderr, "Tcl_Init failed:  %s\n", handle->result);
	exit(1);
    }
    if (Tk_Init(handle) != TCL_OK)  {
	fprintf(stderr, "Tk_Init failed:  %s\n", handle->result);
	exit(1);
    }

    return mainWindow;
}

void c_do_one_tk_event()

{
    Tk_DoOneEvent(TK_ALL_EVENTS);
}

