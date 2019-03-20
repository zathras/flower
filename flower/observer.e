class OBSERVER 
	--  Abstract superclass for objects that want to be notified of
	--  changes happening within an OBSERVABLE.  Cf. the "Observer"
	-- pattern in the GoF book.


feature	{ OBSERVER, OBSERVABLE }	-- Notification

	notify_change is
			-- Called just after an OBSERVABLE is changed
		do
		end;

	notify_release is
			-- Called just before an OBSERVABLE is released
		do
		end;

end -- class OBSERVER
