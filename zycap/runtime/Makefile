#       CROSS_COMPILE = /tools/Xilinx/Vitis/2019.2/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-
CROSS_COMPILE = /tools/Xilinx/Vitis/2019.2/gnu/aarch64/lin/aarch64-linux/bin/aarch64-linux-gnu-
#

CC = $(CROSS_COMPILE)g++
AR = $(CROSS_COMPILE)ar

CFLAGS = -Wall -Wextra -O3 -fpic -Iinc
LDFLAGS = -Wl,-R,. -shared
LDLIBS = -lm -lpthread

OBJS = zycap.o

ZYNQ_OBJS = $(OBJS:%=.aarch32/_build/%)
ZYNQMP_OBJS = $(OBJS:%=.aarch64/_build/%)

MKDIRP = mkdir -p
CPF = cp -f

.PHONY: zynq
zynq: $(ZYNQ_OBJS)
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o .aarch32/zycap.so
	$(AR) rcs .aarch32/zycap.a $^
	$(MKDIRP) .aarch32/include
	$(CPF) inc/zycap.hpp .aarch32/include

.PHONY: zynqmp
zynqmp: $(ZYNQMP_OBJS)
	echo "test"
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o .aarch64/zycap.so
	$(AR) rcs .aarch64/zycap.a $^
	$(MKDIRP) .aarch64/include
	$(CPF) inc/zycap.hpp .aarch64/include

.PHONY: clean
clean:
	rm -rf .aarch32 .aarch64

.aarch32/_build/%.o: src/%.cpp
	$(MKDIRP) $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

.aarch64/_build/%.o: src/%.cpp
	$(MKDIRP) $(@D)
	$(CC) -DZYNQMP $(CFLAGS) -c $< -o $@