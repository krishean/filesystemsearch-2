
RM:=rm -f
CXX:=g++
STRIP:=strip

UNAME_S?=$(shell uname -s)
ifeq ($(UNAME_S), Darwin)
    UNAME_O?=Darwin
else
    UNAME_O?=$(shell uname -o)
endif

BASE_DIR:=..
SRC_DIR:=.
OBJ_DIR:=obj
BIN_DIR:=$(BASE_DIR)/bin

CXX_SRC:=LockObject.cpp \
    Lock.cpp \
    Main.cpp \
    Database.cpp \
    Migrations.cpp \
    Schemas.cpp \
    Fss_File.cpp \
    Indexing.cpp \
    RuntimeState.cpp \
    LocalConfig.cpp
CXX_OBJ:=$(patsubst %.cpp, $(OBJ_DIR)/%.o, $(CXX_SRC))

ifeq ($(UNAME_O), Msys)
    OUT:=$(BIN_DIR)/a.exe
    LDLIBS:=$(LDLIBS) -static-libgcc -static-libstdc++ -Wl,-Bstatic -lstdc++ -lpthread -Wl,-Bdynamic $(BIN_DIR)/sqlite3.dll
    # COPY_FILES:=$(MSYSTEM_PREFIX)/bin/libsqlite3-0.dll
else
    OUT:=$(BIN_DIR)/a.out
    LDLIBS:=$(LDLIBS) -lsqlite3
    # COPY_FILES:=
endif
INCLUDES:=$(INCLUDES) -I$(SRC_DIR)
CPPFLAGS:=$(CPPFLAGS) -std=c++17 -O2 -DNDEBUG -Wall -Wformat
LDLIBS:=$(LDLIBS) -lstdc++fs

all: $(OUT)

$(CXX_OBJ): $(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR)
	$(CXX) $(CPPFLAGS) -c $< -o $@

$(OUT): $(CXX_OBJ) | $(BIN_DIR)
	$(CXX) $(LDFLAGS) -o $@ $+ $(LDLIBS)
#	if [ -n "$(COPY_FILES)" ]; then for file in $(COPY_FILES); do cp -vf $$file $(BIN_DIR); done; fi

$(OBJ_DIR) $(BIN_DIR):
	mkdir -pv $@

strip: $(OUT)
	$(STRIP) $^

clean:
	$(RM) -r $(OBJ_DIR) $(OUT)
