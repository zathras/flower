

TARGET = libeiftcl.a

CFLAGS = -g -I$(EIFFEL3)/bench/spec/$(PLATFORM)/include
OBJS = tcl_interpreter.o tk_application.o

$(TARGET) : $(OBJS)
	rm -f $(TARGET)
	ar -q $(TARGET) $(OBJS)
	ranlib $(TARGET)

.DUMMY:  clean

clean:
	rm -f $(OBJS) $(TARGET)
