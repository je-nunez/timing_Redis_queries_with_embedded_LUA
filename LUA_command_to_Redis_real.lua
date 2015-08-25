
-- replace 'key-to-search' below by the real-key you want to search
-- and then send the line below to the Redis server, e.g., to port
-- 6379. Don't send these comments in LUA to Redis.
-- (See the file "LUA_command_to_Redis_formatted.lua" for a version
-- of the script below in pretty-print format. Custom LUA functions
-- are in upper-case to help to distinguish them in that line.)
--
-- the 'eval ' prefix is not part of LUA, it is for Redis to invoke
-- its embedded LUA module.

eval "local function LUA_TIMESTAMP () local t=redis.call('time'); local s=string.format('%d%06d', t[1], t[2]); return tonumber(s); end; local function LUA_GET (redis_key) return redis.call('get', redis_key) end; local ts_start = LUA_TIMESTAMP(); local redis_value = LUA_GET('key-to-search'); local ts_end = LUA_TIMESTAMP(); local delay = ts_end - ts_start ; return redis_value .. ' (took in Redis server-side ' .. delay .. ' microseconds)'" 0 

