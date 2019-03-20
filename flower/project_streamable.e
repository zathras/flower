deferred class PROJECT_STREAMABLE
	-- Abstract base classes for objects that know how to be read by
	-- a PROJECT_READER and written by a PROJECT_WRITER



feature { PROJECT_READER }		-- Streaming Support

	make_for_reader (reader : PROJECT_READER; args : ARRAYED_LIST [ ANY ]) is
			-- Create a new object using args.  Calls reader.error() if there's
			-- a problem.
		deferred
		end;

feature { PROJECT_WRITER }		-- Streaming Support

	write_for_writer (writer : PROJECT_WRITER) is
		deferred
		end;

end -- class PROJECT_STREAMABLE
