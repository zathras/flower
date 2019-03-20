deferred class LM_CLASS_MEMBER
	-- Abstract class.
	-- Instances represent a member of a class (that is, a method 
	-- or a variable)

inherit
	PROJECT_STREAMABLE
		redefine
			make_for_reader
		end;


feature		-- initialize/release

	make (a_name, a_type : STRING) is
		do
			name := clone(a_name);
			type := clone(a_type);
		end;


feature 	-- Modification

	set_name (a_name : STRING) is
		do
			name := clone(a_name);
		end;

	set_type (a_type : STRING) is
		do
			type := clone(a_type);
		end;


feature		-- Attributes

	name : STRING;
	type : STRING;


feature { PROJECT_READER }		-- Streaming support

	make_for_reader (reader : PROJECT_reader; args : ARRAYED_LIST [ ANY ]) is
		local
			i : INTEGER;
		do
			if args.count /= 2 then
				reader.error("Not enough arguments for class");
			end;
			name ?= args @ 1;
			type ?= args @ 2;
			if name = Void or else type = Void then
				reader.error("Improper class member arguments");
			end
		end;

end 	-- class LM_CLASS_MEMBER
