defmodule APITest do
  use ExUnit.Case
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

  test "incr", ctx do
    client = ctx[:client]

    client |> API.set("mykey", "10")

    assert 11 == client |> API.incr("mykey")
  end

  test "lastsave", ctx do
    client = ctx[:client]

    assert client |> API.lastsave > 1400000000
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

end
