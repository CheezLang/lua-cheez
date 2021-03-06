source_file = "binding_source.c"

function prepend_to_cpp()
    return [[
#include <memory>
extern "C" {
#include "../binding_source.c"
}
]]
end

function prepend_to_cheez()
    return [[
#lib("./lib/binding.lib")
#lib("./lib/lua.lib")

#export_scope

// #defines
lua_tostring :: (L: ^mut lua_State, idx: i32) -> c_string {
    return lua_tolstring(L, idx, null)
}

lua_tonumber :: (L: ^mut lua_State, idx: i32) -> lua_Number {
    return lua_tonumberx(L, idx, null)
}

lua_pop :: (L: ^mut lua_State, n: i32) {
    lua_settop(L, -n - 1)
}

lua_pushcfunction :: (L: ^mut lua_State, f: lua_CFunction) {
    lua_pushcclosure(L, f, 0)
}

lua_register :: (L: ^mut lua_State, n: c_string, f: lua_CFunction) {
    lua_pushcfunction(L, f)
    lua_setglobal(L, n)
}

lua_upvalueindex :: (i: i32) -> i32 {
    return LUA_REGISTRYINDEX - i
}

lua_isfunction :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TFUNCTION }
lua_istable :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TTABLE }
lua_islightuserdata :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TLIGHTUSERDATA }
lua_isnil :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TNIL }
lua_isboolean :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TBOOLEAN }
lua_isthread :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TTHREAD }
lua_isnone :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) == LUA_TNONE }
lua_isnoneornil :: (L: ^mut lua_State, n: i32) -> bool { return lua_type(L, n) <= 0 }

lua_pcall :: (L: ^mut lua_State, nargs: i32, nresults: i32, errfunc: i32) -> i32 {
    return lua_pcallk(L, nargs, nresults, errfunc, 0, null)
}

luaL_dostring :: (L: ^mut lua_State, s: c_string) -> i32 {
    a := luaL_loadstring(L, s)
    if a != 0 {
        return a
    }
    
    return lua_pcall(L, 0, LUA_MULTRET, 0)
}

luaL_loadfile :: (L: ^mut lua_State, s: c_string) -> i32 {
    return luaL_loadfilex(L, s, null)
}

luaL_dofile :: (L: ^mut lua_State, s: c_string) -> i32 {
    a := luaL_loadfile(L, s)
    if a != 0 {
        return a
    }
    
    return lua_pcall(L, 0, LUA_MULTRET, 0)
}

FILE        :: struct {}
lua_State   :: struct {}
luaL_Buffer :: struct {}
CallInfo    :: struct {}
]]
end

function on_global_variable(decl, name, type)
    return true, nil
end

include_typedefs = {
    va_list     = true,
    size_t      = true,
    ptrdiff_t   = true,
}

function on_typedef(decl, name, text)
    if include_typedefs[name] then
        return ""
    end

    index = name:find("lua")
    print("typedef " .. name .. " '" .. text .. "'")
    if (index == nil)
    then
        return nil
    else
        return ""
    end
end

macros = {
    LUA_REGISTRYINDEX   = true,
    LUAI_MAXSTACK       = true,
    LUA_EXTRASPACE      = true,
    LUA_MULTRET         = true,
    LUA_OK              = true,
    LUA_YIELD           = true,
    LUA_ERRRUN          = true,
    LUA_ERRSYNTAX       = true,
    LUA_ERRMEM          = true,
    LUA_ERRGCMM         = true,
    LUA_ERRERR          = true,
    LUA_TNONE           = true,
    LUA_TNIL            = true,
    LUA_TBOOLEAN        = true,
    LUA_TLIGHTUSERDATA  = true,
    LUA_TNUMBER         = true,
    LUA_TSTRING         = true,
    LUA_TTABLE          = true,
    LUA_TFUNCTION       = true,
    LUA_TUSERDATA       = true,
    LUA_TTHREAD         = true,
    LUA_GCSTOP          = true,
    LUA_GCRESTART       = true,
    LUA_GCCOLLECT       = true,
    LUA_GCCOUNT         = true,
    LUA_GCCOUNTB        = true,
    LUA_GCSTEP          = true,
    LUA_GCSETPAUSE      = true,
    LUA_GCSETSTEPMUL    = true,
    LUA_GCISRUNNING     = true,
    LUA_GCGEN           = true,
    LUA_GCINC           = true,
    
}

function on_macro(decl, name)
    if name == "LUA_EXTRASPACE" then return true, (name .. " :: @sizeof(^void)") end
    if macros[name] then return false, nil end

    return true, nil
end

function on_function(decl, name)
    index = name:find("lua")
    if (index == nil)
    then
        -- doesn't start with glfw*, so don't emit anything
        return true, nil
    else
        -- starts with glfw*, so emit default
        return false, nil
    end
end

function on_struct(decl, name)
    print("struct " .. name)
    if name == "luaL_Buffer" then
        return true, nil
    end

    index = name:find("lua")
    if (index == nil)
    then
        return true, nil
    else
        return false, nil
    end
end

function on_union(decl, name)
    print("union " .. name)
    return false, nil
end

function on_enum(enum)
    print("enum " .. name)
    index = name:find("lua")
    if (index == nil)
    then
        return nil
    else
       return false, enum
    end
end