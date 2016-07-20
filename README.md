# :metal: Sider – A Redis client in Elixir :metal:

## NOTHING TO SEE HERE YET!

```elixir
iex> "redis" |> String.reverse
sider
```

Me learning how to write a Redis client library for great justice!

While this is a mostly educational endeavour, I hope to have a complete implementation with support for all the major features of Redis.

## Connect to Redis

```elixir
{:ok, client} = Sider.start_link
```

## Disconnect from Redis

```elixir
client |> Sider.stop
```

## Set & Get

```elixir
# set
client |> Sider.query ["SET", "FOO", "BAR"]

# get
client |> Sider.query ["GET", "FOO"]
# => "BAR"
```

## References

* [Redis Protocol specification](http://redis.io/topics/protocol)
* [Exredis](https://github.com/artemeff/exredis)

