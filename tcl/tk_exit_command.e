
	-- This is the command that causes TK_APPLICATION to drop out of the
	-- event loop.


class TK_EXIT_COMMAND inherit

	TCL_COMMAND
		redefine
			evaluate, name
		end;

	EXCEPTIONS

creation

	make

feature		-- Initialilze/Release

	make (app : TK_APPLICATION) is
		do
			application := app;
		end;


feature		-- Attributes

	name : STRING is "exit";

feature { TCL_INTERPRETER }		-- Command invocation

	evaluate (args : ARRAY[STRING]) : STRING is
		do
			if args.lower <= args.upper then
				raise("wrong # of arguments:  should be 'eiffel exit'");
			end
			application.exit;
			Result := "";
		end;


feature { NONE } 	-- private

	application : TK_APPLICATION;


end -- class TK_EXIT_COMMAND
