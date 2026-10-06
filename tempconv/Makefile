AS      := as
LD      := ld
ARCH    := arm64
SDKROOT := $(shell xcrun --show-sdk-path)

SRC     := src/tempconv.s
OBJ     := build/tempconv.o
BIN     := bin/tempconv

.PHONY: all clean test

all: $(BIN)

$(BIN): $(OBJ) | bin
	$(LD) -o $@ -lSystem -syslibroot "$(SDKROOT)" -e _main -arch $(ARCH) $<

$(OBJ): $(SRC) | build
	$(AS) -arch $(ARCH) -o $@ $<

build bin:
	mkdir -p $@

clean:
	rm -rf build bin

test:
	./test/run_tests.sh
