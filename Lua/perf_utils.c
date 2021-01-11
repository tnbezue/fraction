#include <time.h>

#if defined (__cplusplus)
extern "C"
{
#endif

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#if defined (__cplusplus)
}
#endif

static int pref_utils_clock_gettime_in_ns(lua_State* L)
{
  clockid_t cid = lua_tointeger(L, -1);
  struct timespec ts;
  clock_gettime(cid,&ts);
  lua_pushinteger(L,ts.tv_sec*1000000000 +ts.tv_nsec);
  return 1;
}

LUAMOD_API int luaopen_perf_utils(lua_State* L)
{
  lua_pushinteger(L,CLOCK_REALTIME);
  lua_setglobal(L,"CLOCK_REALTIME");
  lua_pushinteger(L,CLOCK_MONOTONIC);
  lua_setglobal(L,"CLOCK_MONOTONIC");
  lua_pushinteger(L,CLOCK_PROCESS_CPUTIME_ID);
  lua_setglobal(L,"CLOCK_PROCESS_CPUTIME_ID");
  lua_pushinteger(L,CLOCK_THREAD_CPUTIME_ID);
  lua_setglobal(L,"CLOCK_THREAD_CPUTIME_ID");
  lua_pushcfunction(L,pref_utils_clock_gettime_in_ns);
  lua_setglobal(L,"clock_gettime_in_ns");
  return 0;
}
