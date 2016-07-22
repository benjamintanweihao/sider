defmodule APITest do
  use ExUnit.Case, async: true
  alias Sider.API

  setup do
    {:ok, client} = Sider.start_link
    client |> Sider.query(["FLUSHALL"])

    {:ok, [client: client]}
  end

  test "append", ctx do
    client = ctx[:client]

    assert 5  == client |> API.append("mykey", "Hello")
    assert 11 == client |> API.append("mykey", " World")
  end

  test "bitcount", ctx do
    client = ctx[:client]

    client |> API.append("mykey", "foobar")

    assert 26 == client |> API.bitcount("mykey")
    assert 4  == client |> API.bitcount("mykey", 0, 0)
    assert 6  == client |> API.bitcount("mykey", 1, 1)
  end

  test "dbsize", ctx do
    client = ctx[:client]

    client |> API.sadd("set1", "foo")
    assert 1 == client |> API.dbsize

    client |> API.sadd("set2", "bar")
    assert 2 == client |> API.dbsize

    client |> API.sadd("set2", ["foo", "bar"])
    assert 2 == client |> API.dbsize
  end

  test "decr", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "10")

    assert 9 == client |> API.decr("mykey")
  end

  test "decrby", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "10")

    assert 7 == client |> API.decrby("mykey", "3")
  end

  test "flushall", ctx do
    client = ctx[:client]

    client |> API.sadd("set1", "foo")
    client |> API.sadd("set2", "bar")

    assert 2 == client |> API.dbsize

    client |> API.flushall

    assert 0 == client |> API.dbsize
  end

  test "flushdb", ctx do
    client = ctx[:client]

    client |> API.sadd("set1", "foo")
    client |> API.sadd("set2", "bar")

    assert 2 == client |> API.dbsize

    client |> API.flushdb

    assert 0 == client |> API.dbsize
  end

  test "geoadd/geodist/georadius", ctx do
    client = ctx[:client]

    assert 2 == client |> API.geoadd("Sicily", [13.361389, 38.115556, "Palermo", 15.087269, 37.502669, "Catania"])
    assert "166274.1516" == client |> API.geodist("Sicily", "Palermo", "Catania")
    assert ["Catania"] == client |> API.georadius("Sicily", 15, 37, 100, "km")
    assert ["Palermo", "Catania"] == client |> API.georadius("Sicily", 15, 37, 200, "km")
  end

  test "geohash", ctx do
    client = ctx[:client]

    assert 2 == client |> API.geoadd("Sicily", [13.361389, 38.115556, "Palermo", 15.087269, 37.502669, "Catania"])
    assert ["sqc8b49rny0", "sqdtr74hyu0"] == client |> API.geohash("Sicily", ["Palermo", "Catania"])
  end

  test "get/set", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "Hello")

    assert "Hello" == client |> API.get("mykey")
  end

  test "getbit/setbit", ctx do
    client = ctx[:client]

    assert 0 == client |> API.setbit("mykey", 7, 1)
    assert 0 == client |> API.getbit("mykey", 0)
    assert 1 == client |> API.getbit("mykey", 7)
    assert 0 == client |> API.getbit("mykey", 100)
  end

  test "getrange", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "This is a string")

    assert "This" == client |> API.getrange("mykey", 0, 3)
    assert "ing"  == client |> API.getrange("mykey", -3, -1)
    assert "This is a string" == client |> API.getrange("mykey", 0, -1)
    assert "string" == client |> API.getrange("mykey", 10, 100)
  end

  test "getset", ctx do
    client = ctx[:client]

    assert 1 == client |> API.incr("mycounter")
    client |> API.getset("mycounter", 0)

    assert "0" == client |> API.get("mycounter")
  end

  test "hdel/hset", ctx do
    client = ctx[:client]

    assert 1 == client |> API.hset("myhash", "field1", "foo")
    assert 1 == client |> API.hdel("myhash", "field1")
    assert 0 == client |> API.hdel("myhash", "field2")
  end

  test "hget", ctx do
    client = ctx[:client]

    assert 1     == client |> API.hset("myhash", "field1", "foo")
    assert "foo" == client |> API.hget("myhash", "field1")
    assert nil   == client |> API.hget("myhash", "field2")
  end

  test "hgetall", ctx do
    client = ctx[:client]

    client |> API.hset("myhash", "field1", "Hello")
    client |> API.hset("myhash", "field2", "World")

    expected = ["field1", "Hello", "field2", "World"]
    assert expected == client |> API.hgetall("myhash")
  end

  test "hincrby", ctx do
    client = ctx[:client]

    assert 1  == client |> API.hset("myhash", "field", 5)
    assert 6  == client |> API.hincrby("myhash", "field", 1)
    assert 5  == client |> API.hincrby("myhash", "field", -1)
    assert -5 == client |> API.hincrby("myhash", "field", -10)
  end

  test "hincrbyfloat", ctx do
    client = ctx[:client]

    assert 1  == client |> API.hset("mykey", "field", 10.50)

    # expected = "10.60000000000000001"
    expected = "10.6"
    assert expected == client |> API.hincrbyfloat("mykey", "field", 0.1)

    # expected = "5.59999999999999964"
    expected = "5.6"
    assert expected == client |> API.hincrbyfloat("mykey", "field", -5)

    assert 0 == client |> API.hset("mykey", "field", 5.0e3)

    assert "5200" == client |> API.hincrbyfloat("mykey", "field", 2.0e2)
  end

  test "hexists", ctx do
    client = ctx[:client]

    assert 1 == client |> API.hset("myhash", "field1", "foo")
    assert 1 == client |> API.hexists("myhash", "field1")
    assert 0 == client |> API.hexists("myhash", "field2")
  end

  test "hkeys", ctx do
    client = ctx[:client]

    assert 1 == client |> API.hset("myhash", "field1", "Hello")
    assert 1 == client |> API.hset("myhash", "field2", "World")
    assert ["field1", "field2"] == client |> API.hkeys("myhash")
  end

  test "hlen", ctx do
    client = ctx[:client]

    client |> API.hset("myhash", "field1", "Hello")
    client |> API.hset("myhash", "field2", "World")

    assert 2 == client |> API.hlen("myhash")
  end

  test "hset/hmget", ctx do
    client = ctx[:client]

    client |> API.hset("myhash", "field1", "Hello")
    client |> API.hset("myhash", "field2", "World")

    assert ["Hello", "World", nil] == client |> API.hmget("myhash", ["field1", "field2", "nofield"])
  end

  test "hmset", ctx do
    client = ctx[:client]

    client |> API.hmset("myhash", ["field1", "Hello", "field2", "World"])

    assert "Hello" == client |> API.hget("myhash", "field1")
    assert "World" == client |> API.hget("myhash", "field2")
  end

  test "hsetnx", ctx do
    client = ctx[:client]

    assert 1 == client |> API.hsetnx("myhash", "field", "Hello")
    assert 0 == client |> API.hsetnx("myhash", "field", "World")
    assert "Hello" == client |> API.hget("myhash", "field")
  end

  test "hstrlen", ctx do
    client = ctx[:client]

    client |> API.hmset("myhash", ["f1", "HelloWorld", "f2", "99", "f3", "-256"])

    assert 10 == client |> API.hstrlen("myhash", "f1")
    assert 2  == client |> API.hstrlen("myhash", "f2")
    assert 4  == client |> API.hstrlen("myhash", "f3")
  end

  test "hvals", ctx do
    client = ctx[:client]

    client |> API.hset("myhash", "field1", "Hello")
    client |> API.hset("myhash", "field2", "World")

    assert ["Hello", "World"] == client |> API.hvals("myhash")
  end

  test "incr", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "10")

    assert 11 == client |> API.incr("mykey")
  end

  test "incrby", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "10")
    assert 15 == client |> API.incrby("mykey", 5)
  end

  test "incrbyfloat", ctx do
    client = ctx[:client]

    client |> API.set("mykey", 10.50)

    assert "10.6" == client |> API.incrbyfloat("mykey", 0.1)
    assert "5.6"  == client |> API.incrbyfloat("mykey", -5)

    client |> API.set("mykey", 5.0e3)

    assert "5200" == client |> API.incrbyfloat("mykey", 2.0e2)
  end

  test "lastsave", ctx do
    client = ctx[:client]

    assert client |> API.lastsave > 1400000000
  end

  test "keys", ctx do
    client = ctx[:client]

    client |> API.mset(["one", "1", "two", "2", "three", "3", "four", "4"])

    assert ["two", "four", "one"] |> Enum.sort == client |> API.keys("*o*") |> Enum.sort
    assert ["two"] |> Enum.sort == client |> API.keys("t??") |> Enum.sort
    assert ["three", "two", "four", "one"] |> Enum.sort == client |> API.keys("*") |> Enum.sort
  end

  test "lindex/lpush", ctx do
    client = ctx[:client]

    assert 1 == client |> API.lpush("mylist", "World")
    assert 2 == client |> API.lpush("mylist", "Hello")

    assert "Hello" == client |> API.lindex("mylist", 0)
    assert "World" == client |> API.lindex("mylist", -1)
    assert nil     == client |> API.lindex("mylist", 3)
  end

  test "lpushhx/lrange", ctx do
    client = ctx[:client]

    assert 1 == client |> API.lpush("mylist", "World")
    assert 2 == client |> API.lpushx("mylist", "Hello")
    assert 0 == client |> API.lpushx("myotherlist", "Hello")
    assert ["Hello", "World"] == client |> API.lrange("mylist", 0, -1)
    assert [] == client |> API.lrange("myotherlist", 0, -1)
  end

  test "lrem", ctx do
    client = ctx[:client]

    assert 1 == client |> API.rpush("mylist", "hello")
    assert 2 == client |> API.rpush("mylist", "hello")
    assert 3 == client |> API.rpush("mylist", "foo")
    assert 4 == client |> API.rpush("mylist", "hello")

    assert 2 == client |> API.lrem("mylist", -2, "hello")
  end

  test "lset", ctx do
    client = ctx[:client]

    assert 1 == client |> API.rpush("mylist", "one")
    assert 2 == client |> API.rpush("mylist", "two")
    assert 3 == client |> API.rpush("mylist", "three")
    client |> API.lset("mylist", 0, "four")
    client |> API.lset("mylist", -2, "five")

    assert ["four", "five", "three"] == client |> API.lrange("mylist", 0, -1)
  end

  test "ltrim", ctx do
    client = ctx[:client]

    assert 1 == client |> API.rpush("mylist", "one")
    assert 2 == client |> API.rpush("mylist", "two")
    assert 3 == client |> API.rpush("mylist", "three")
    client |> API.ltrim("mylist", 1, -1)

    assert ["two", "three"] == client |> API.lrange("mylist", 0, -1)
  end

  test "mget", ctx do
    client = ctx[:client]

    client |> API.set("key1", "Hello")
    client |> API.set("key2", "World")

    assert ["Hello", "World", nil] == client |> API.mget(["key1", "key2", "nonexisting"])
  end

  test "mset", ctx do
    client = ctx[:client]

    client |> API.mset(["key1", "Hello", "key2", "World"])

    assert "Hello" == client |> API.get("key1")
    assert "World" == client |> API.get("key2")
  end

  test "msetnx", ctx do
    client = ctx[:client]

    assert 1 == client |> API.msetnx(["key1", "Hello", "key2", "there"])
    assert 0 == client |> API.msetnx(["key2", "there", "key3", "world"])
    assert ["Hello", "there", nil] == client |> API.mget(["key1", "key2", "key3"])
  end

  test "ping", ctx do
    client = ctx[:client]

    assert "PONG" == client |> API.ping
    assert "hello world" == client |> API.ping("hello world")
  end

  test "sadd", ctx do
    client = ctx[:client]

    assert 1 == client |> API.sadd("set1", "bar")
    assert 2 == client |> API.sadd("set2", ["bar", "foo"])
  end

  test "sdiff", ctx do
    client = ctx[:client]

    client |> API.sadd("set1", "bar")
    client |> API.sadd("set2", ["bar", "foo"])

    assert ["foo"] == client |> API.sdiff(["set2", "set1"])
  end

  test "sdiffstore", ctx do
    client = ctx[:client]

    client |> API.sadd("set1", "bar")
    client |> API.sadd("set2", ["bar", "foo"])

    assert 1 == client |> API.sdiffstore("dest", ["set2", "set1"])
  end

  test "zadd/zrange", ctx do
    client = ctx[:client]

    assert 1 == client |> API.zadd("myzset", [1, "one"])
    assert 1 == client |> API.zadd("myzset", [1, "uno"])
    assert 2 == client |> API.zadd("myzset", [2, "two", 3, "three"])

    expected = ["one", "1", "uno", "1", "two", "2", "three", "3"]

    assert expected == client |> API.zrange("myzset", 0, -1, "WITHSCORES")
  end

  test "zcard", ctx do
    client = ctx[:client]

    assert 1 == client |> API.zadd("myzset", [1, "one"])
    assert 1 == client |> API.zadd("myzset", [2, "two"])

    assert 2 == client |> API.zcard("myzset")
  end

  test "zcount", ctx do
    client = ctx[:client]

    assert 1 == client |> API.zadd("myzset", [1, "one"])
    assert 1 == client |> API.zadd("myzset", [2, "two"])
    assert 1 == client |> API.zadd("myzset", [3, "three"])

    assert 3 == client |> API.zcount("myzset", "-inf", "+inf")
    assert 2 == client |> API.zcount("myzset", "(1", "3")
  end

  test "zincrby", ctx do
    client = ctx[:client]

    assert 1 == client |> API.zadd("myzset", [1, "one"])
    assert 1 == client |> API.zadd("myzset", [2, "two"])
    assert "3" == client |> API.zincrby("myzset", 2, "one")

    expected = ["two", "2", "one", "3"]
    assert expected == client |> API.zrange("myzset", 0, -1, "WITHSCORES")
  end

  test "zlexcount", ctx do
    client = ctx[:client]

    assert 5 == client |> API.zadd("myzset", [0, "a", 0, "b", 0, "c", 0, "d", 0, "e"])
    assert 2 == client |> API.zadd("myzset", [0, "f", 0, "g"])

    assert 7 == client |> API.zlexcount("myzset", "-", "+")
    assert 5 == client |> API.zlexcount("myzset", "[b", "[f")
  end

  test "zrank", ctx do
    client = ctx[:client]

    assert 1   == client |> API.zadd("myzset", [1, "one"])
    assert 1   == client |> API.zadd("myzset", [2, "two"])
    assert 1   == client |> API.zadd("myzset", [3, "three"])
    assert 2   == client |> API.zrank("myzset", "three")
    assert nil == client |> API.zrank("myzset", "four")
  end

  test "zrem", ctx do
    client = ctx[:client]

    assert 1 == client |> API.zadd("myzset", [1, "one"])
    assert 1 == client |> API.zadd("myzset", [2, "two"])
    assert 1 == client |> API.zadd("myzset", [3, "three"])
    assert 1 == client |> API.zrem("myzset", "two")
    assert ["one", "1", "three" ,"3"] == client |> API.zrange("myzset", 0, -1, "WITHSCORES")
  end

  test "zrevrank", ctx do
    client = ctx[:client]

    assert 1   == client |> API.zadd("myzset", [1, "one"])
    assert 1   == client |> API.zadd("myzset", [2, "two"])
    assert 1   == client |> API.zadd("myzset", [3, "three"])
    assert 2   == client |> API.zrevrank("myzset", "one")
    assert nil == client |> API.zrevrank("myzset", "four")
  end

  test "zscore", ctx do
    client = ctx[:client]

    assert 1   == client |> API.zadd("myzset", [1, "one"])
    assert "1"   == client |> API.zscore("myzset", "one")
  end

end
