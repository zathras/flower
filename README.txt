Flower CASE Tool

I have a working prototype of a Case tool that I'm calling "flower" for now.
It's written in Eiffel, and used Tcl/Tk for the GUI layer. I'm developing it
under Linux, but it should run under any platform that supports the ISE Eiffel
environment and Tcl/Tk (Tcl version 7.4, and Tk version 4.0). As soon as Tck/Tk
are available for Windows/NT, this tool should work there.

The prototype is still a little rough around the edges, but it can be used to
edit diagrams, and it supports loading and saving them. It supports a subset of
the symbols on a Rumbaugh class diagram (Class, Association, Aggretation, and
Generalization). Here's some of what it doesn't support:

   * Many of the symbols needed for proper Rumbaugh class diagrams, like
     objects and attributed relationships.
   * Labels or roles on relationships.
   * Free text on diagrams.
   * Printing. It looks like Tk does most of the work for me, but I haven't
     implemented this yet.
   * Anything that's not on a Rumbaugh class diagram.
   * Deleting figures from a diagram.
   * Closing or deleting a diagram.

Also, the code could stand a bit of cleanup and refactoring, and I've made no
effort whatsoever to make it fast. Like I said, it's a prototype! :-)

If you'd like Linux binaries, e-mail me (preferably with a location where I can
put the file up for anonymous ftp :-). The source is available here. Finally,
here is a sample diagram.

I'm interested in feedback!

If you've taken a look at Flower, I'm like your feedback. I'd like to know:

   * How much interest there is in my making a complete, polished version.
   * Any comment (good or bad) you might have on the design of the tool.
   * Any comments on my Eiffel coding style. This is the first project I've
     done in Eiffel, so I'd like to know how I did :-)

I can be reached at billf@jovial.com.

                                 | Home Page |
