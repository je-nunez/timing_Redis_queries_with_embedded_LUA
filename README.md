# timing Redis queries with embedded LUA

Using embedded LUA in Redis to time, server-side, its GET queries.

# WIP

This project is a *work in progress*. The implementation is *incomplete* and
subject to change. The documentation can be inaccurate.

# Description

Sometimes it is useful to see `how long` an operation took in the
`server-side`, ie., ignoring network delays and queueing of socket
requests, etc, like many SQL database server do, like the timing at
the end of:

    > SELECT ... FROM ...
         ....
         .... <resulting-rows>
         ....
        <n> rows selected (0.01 sec)

The delay in the block above is typical from the timing profile given
by different SQL servers. This project is for an embedded LUA into Redis
answering a similar timing profile, so the client gets the value of the
GET query in Redis, `plus the delay it took inside Redis`:

    <VALUE> (took in Redis server-side 68 microseconds)

and, if the same GET query were repeated in Redis, it can show:
 
    <VALUE> (took in Redis server-side 27 microseconds)

where the delay of the query has changed now.

# How to use:

Replace the string `'key-to-search'` in `LUA_command_to_Redis_real.lua`
in this repository, and send that line as-is to the Redis server
(e.g., to its port 6379 if it is listening there). Redis will then
answer a `multi bulk reply` whose `first entry is the value of the key`,
and the `second entry` is a string in the format:

    Timing delay in Redis server-side (microseconds): <DELAY>

with the profiling total delay. (There was an older version of this
script which made Redis answer, instead of a multi bulk reply, a
string in the format:

    <VALUE> (took in Redis server-side <DELAY> microseconds)
)

There is also a script `LUA_command_to_Redis_logging_version_real.lua`
similar to the above, but which does not affect Redis normal output
and instead logs the delays of the GET queries to the log mechanism
Redis is using (syslog, log-file, etc). It has thresholds of delays
to see with which syslog-priority (`Warning`, `Debug`, etc) to log
the delay that Redis gave.

Both scripts can be modified. The scripts `LUA_*_formatted.lua` here
are the human-friendly versions of the `LUA_*_real.lua` to send to
Redis.

# See also:

See also in Redis the [EVALSHA](http://redis.io/commands/evalsha "EVALSHA")
instruction, to submit a Lua script for `preparation` for (repeated)
future execution.

Also [config get lua-time-limit](http://redis.io/commands/EVAL "config get lua-time-limit")
to see a parameter that affects somehow the maximum execution time
allowable for a script,

and [config get slowlog-log-slower-than](http://redis.io/commands/slowlog "config get slowlog-log-slower-than")
for a way to log when an operation or query in Redis takes too long in the
server-side.

