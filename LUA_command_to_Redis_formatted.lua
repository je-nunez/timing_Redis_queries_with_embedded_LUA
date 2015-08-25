
-- This is a version of the line in file "LUA_command_to_Redis_real.lua"
-- to send to the embedded LUA interpreter in the Redis server.
--
-- It measures the delay, server-side, of a GET query in Redis.
--
-- (Custom LUA functions are in upper-case as a notation to help to quickly
-- distinguish them for Redis -see file "LUA_command_to_Redis_real.lua".)

local function LUA_TIMESTAMP ()
    local t=redis.call('time');
    local s=string.format('%d%06d', t[1], t[2]);
    return tonumber(s);
end;

local function LUA_GET (redis_key)
    return redis.call('get', redis_key)
end;

local ts_start = LUA_TIMESTAMP();

local redis_value = LUA_GET('key-to-search');

local ts_end = LUA_TIMESTAMP();
local delay = ts_end - ts_start;

return redis_value .. ' (took in Redis server-side ' .. delay .. ' microseconds)'

