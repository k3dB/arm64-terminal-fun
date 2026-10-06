AS      := as
LD      := ld
ARCH    := arm64
SDKROOT := $(shell xcrun --show-sdk-path)

SRCS    := $(wildcard src/*.s)
INCS    := $(wildcard src/*.inc)
OBJS    := $(patsubst src/%.s,build/%.o,$(SRCS))
BIN     := bin/tempconv

.PHONY: all clean test

all: $(BIN)

$(BIN): $(OBJS) | bin
	$(LD) -o $@ -lSystem -syslibroot "$(SDKROOT)" -e _main -arch $(ARCH) $^

build/%.o: src/%.s $(INCS) | build
	$(AS) -arch $(ARCH) -I src -o $@ $<

build bin:
	mkdir -p $@

clean:
	rm -rf build bin

test:
	./test/run_tests.sh
