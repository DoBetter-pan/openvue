#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <cstring>
#include <vector>
#include <stdint.h>
#include "ahocorasick.h"
#include "aho_corasick.hpp"

static int search(lua_State *L);

static int search(lua_State *L) {
    aho_corasick::trie trie;
    std::string str = lua_tostring(L, 1);
    if (lua_istable(L, 2)) {
        lua_pushnil(L);
        while(lua_next(L, 2) != 0) {
            if (lua_isstring(L, -1)) {
                trie.insert(lua_tostring(L, -1));
            }
            lua_pop(L, 1);
        }
    }
    lua_pop(L, 1);
    lua_pop(L, 1);

    auto result = trie.parse_text(str);
    lua_newtable(L);
    int i = 1;
    for(auto it = result.begin(); it != result.end(); it++, i++) {
        lua_pushinteger(L, i);
        lua_newtable(L);
        lua_pushnumber(L, it->get_start());
        lua_setfield(L, 3, "start");
        lua_pushnumber(L, it->get_end());
        lua_setfield(L, 3, "end");
        lua_pushstring(L, it->get_keyword().c_str());
        lua_setfield(L, 3, "keyword");
        lua_settable(L, 1);
    }

	return 1;
}

static const luaL_Reg myLib[] = 
{    
	{"search", search},
	{NULL, NULL}       //数组中最后一对必须是{NULL, NULL}，用来表示结束    
};
 
int luaopen_ahocorasick(lua_State *L)
{
	luaL_register(L, "ahocorasick", myLib);
	return 1;		// 把myLib表压入了栈中，所以就需要返回1
}


