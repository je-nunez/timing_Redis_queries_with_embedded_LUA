# timing Redis with embedded LUA

Using embedded LUA in Redis to time, server-side, its GET queries.

# WIP

This project is a *work in progress*. The implementation is *incomplete* and
subject to change. The documentation can be inaccurate.

# Description

Sometimes it is useful to see `how long` an operation took in the
`server-side`, ie., ignoring network delays and queueing of socket
requests, like many SQL database server do, like the timing at the
end of:

    > SELECT ... FROM ...
         ....
         .... <resulting-rows>
         ....
        <n> rows selected (0.01 sec)

This embedded LUA into Redis is for this, answering to the client
the value of a GET query in Redis:

    <VALUE> (took in Redis server-side 68 microseconds)

and, if the same GET query were repeated in Redis, it can show:
 
    <VALUE> (took in Redis server-side 27 microseconds)

where the delay of the query has changed now.

# How to use:

Replace the string `'key-to-search'` in `LUA_command_to_Redis_real.lua`
in this repository, and send that line as-is to the Redis server
(e.g., to its port 6379 if it is listening there).

It will answer the `value` of the `key` in Redis, appending a suffix
with the time it took in the server-side, in this format:

    <VALUE> (took in Redis server-side 68 microseconds)

It can be modified. The script `LUA_command_to_Redis_formatted.lua` is
the human-friendly version of `LUA_command_to_Redis_real.lua`.

