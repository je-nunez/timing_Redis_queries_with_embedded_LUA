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

The LUA wrapper with the `time` calls can be made flexible by seeing which
commands Redis classifies as `read-only` and not `random`, by using the
`command info` Redis stat:

     command info exists
     1) 1) "exists"
        2) (integer) 2
        3) 1) readonly
           2) fast
        ...

     command info ttl
     1) 1) "ttl"
        2) (integer) 2
        3) 1) readonly
           2) fast

     command info time
     1) 1) "time"
        2) (integer) 1
        3) 1) readonly
           2) random
        ...

so `EXISTS` and `TTL` commands are classified as `readonly` and not `random`
by Redis, so they can be intercepted. Then, for such a generic command `X`
of Redis which is `readonly` and not `random`, its valid actual parameters 
among any `arbitrary` call can be found with the
[command getkeys](http://redis.io/commands/command-getkeys "command getkeys")
Redis option, which is able to parse and select which arguments are syntactically
valid in a call and which aren't, so that the LUA interceptor for these
`readonly` and not `random` queries also drops the unnecessary arguments
`command getkeys` has said so.

The command `info` on the section `commandstats` can be useful to pick
which commands are the ones that need to be wrapped with LUA timing,
or to what delay to lower the `config get slowlog-log-slower-than` to so
that operations with a higher delay are logged, since `info commandstats`
shows both the more frequent commands, and the average delay per call
of each command, so any delay higher than this average, can be logged:

      > info commandstats
        # Commandstats
        cmdstat_get:calls=40865153011,usec=98768455102,usec_per_call=2.42
        ...
        cmdstat_exists:calls=59271782476,usec=119277054138,usec_per_call=2.01
        ...
        cmdstat_ping:calls=33252320,usec=48433512,usec_per_call=1.46
        ...

