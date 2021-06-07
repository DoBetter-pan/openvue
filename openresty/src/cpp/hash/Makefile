LUA_LIB_DIR=/opt/openresty/lua/lib/
#LUA_LIB_DIR=/usr/local/openresty/luajit/

# Tools
CC=g++
LD=g++

# Default arguments
CFLAGS=-c -fno-strict-aliasing -fPIC -Wall -DNDEBUG -D_REENTRANT -DLUA_USE_LINUX
LDFLAGS=-shared -fPIC -Wall
INCLUDE=-I/opt/openresty/lua/include/

# Description blocks
all: hash.so

hash.so: hash.o
	$(LD) $(LDFLAGS) -o $@ $^

.cpp.o:
	$(CC) $(INCLUDE) $(CFLAGS) $^
.cc.o:
	$(CC) $(INCLUDE) $(CFLAGS) $^

clean:
	-rm -f hash.so *.o
