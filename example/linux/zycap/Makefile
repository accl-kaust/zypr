APP = zycap

# Add any other object files to this list below
APP_OBJS = zycap.o

all: $(APP)

$(APP): $(APP_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS)

clean:
	-rm -f $(APP) *.elf *.gdb *.o


