
-- replace 'key-to-search' below by the real-key you want to search
-- and then send the line below to the Redis server, e.g., to port
-- 6379. Don't send these comments in LUA to Redis.
-- (See the file "LUA_command_to_Redis_formatted.lua" for a version
-- of the script below in pretty-print format. Custom LUA functions
-- are in upper-case to help to distinguish them in that line.)
--
-- the 'eval ' prefix is not part of LUA, it is for Redis to invoke
-- its embedded LUA module.

eval "local function LUA_TIMESTAMP () local t=redis.call('time'); local s=string.format('%d%06d', t[1], t[2]); return tonumber(s); end; local function LUA_GET (redis_key) local res = redis.pcall('get', redis_key); if type(res) == 'table' and res[1] == 'err' then return 'not found'; elseif type(res) == 'boolean' and res then return 'found-only-true-value'; elseif type(res) == 'boolean' and not res then return 'error-not-found'; else return res; end; end; local ts_start = LUA_TIMESTAMP(); local redis_value = LUA_GET(KEYS[1]); local lua_redis_multibulk={}; lua_redis_multibulk[1] = redis_value; local ts_end = LUA_TIMESTAMP(); local delay = ts_end - ts_start; lua_redis_multibulk[2] = 'Timing delay in Redis server-side (microseconds): ' .. delay; return lua_redis_multibulk;"  1  key-to-search

