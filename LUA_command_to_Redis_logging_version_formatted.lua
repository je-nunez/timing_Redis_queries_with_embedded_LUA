
-- This is a version of the LUA Redis GET wrapper which logs the
-- delay to the log Redis is using (syslog, etc).
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
    local res = redis.pcall('get', redis_key);
    if type(res) == 'table' and res[1] == 'err' then
       return 'not found';
    elseif type(res) == 'boolean' and res then
       return 'found-only-true-value';
    elseif type(res) == 'boolean' and not res then
       return 'error-not-found';
    else
       return res;
    end;
end;


local ts_start = LUA_TIMESTAMP();

local redis_value = LUA_GET(KEYS[1]);

local ts_end = LUA_TIMESTAMP();

local delay = ts_end - ts_start;

local log_str = string.format('GET %s = %s took %d microseconds', KEYS[1], redis_value, delay);
local delay_threshold_microseconds = 100;
local log_level = (delay > delay_threshold_microseconds) and redis.LOG_WARNING or redis.LOG_DEBUG;

redis.log(log_level, log_str);

return redis_value;

