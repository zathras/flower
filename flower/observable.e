class OBSERVABLE 
	-- Represents items that can be observed.  An OBSERVABLE can
	-- have multiple dependants.  Whenever an OBSERVABLE changes,
	-- it will broadcast a notification to its OBSERVERs.
	--
	-- This is what is called "SUBJECT" in the GoF patterns book.

feature		-- Initialize/Release

	init_observable is
		do
			!!observers.make(0);
		end;


feature { OBSERVER }		-- Attachment

	add_observer (o : OBSERVER) is
		do
			observers.extend(o);
		end;

	remove_observer (o : OBSERVER) is
		do
			observers.prune_all(o);
		end;

feature { OBSERVABLE }		-- Notification
	-- These features should be invoked by subclasses to broadcast
	-- change notifications

	notify_change is
		local
			i : INTEGER
		do
			from i := 1 until i > observers.count loop
				(observers @ i).notify_change;
				i := i + 1;
			end;
		end;

	notify_release is
		local
			i : INTEGER
		do
			from i := 1 until i > observers.count loop
				(observers @ i).notify_release;
				i := i + 1;
			end;
		end;

feature { NONE }		-- Attributes

	observers : ARRAYED_LIST [ OBSERVER ];


end -- class OBSERVABLE
