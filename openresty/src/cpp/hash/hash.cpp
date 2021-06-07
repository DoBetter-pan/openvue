#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <cstring>
#include <stdint.h>
#include "hash.h"

static int bkdrhash(lua_State *L);

static int bkdrhash_(const std::string &str){
    int seed = 131;

    int hash = 0;

    for (size_t i = 0; i < str.length(); i++) {
        hash = hash * seed + (int)str.at(i);
    }

    return hash & 0x7FFFFFFF;
}


static int bkdrhash(lua_State *L) {
    std::string data = lua_tostring(L, 1);

    int hash = bkdrhash_(data);
    lua_pushnumber(L, hash);
    
	return 1;
}

static const luaL_Reg myLib[] = 
{    
	{"bkdrhash", bkdrhash},
	{NULL, NULL}       //数组中最后一对必须是{NULL, NULL}，用来表示结束    
};
 
int luaopen_hash(lua_State *L)
{
	luaL_register(L, "hash", myLib);
	return 1;		// 把myLib表压入了栈中，所以就需要返回1
}


