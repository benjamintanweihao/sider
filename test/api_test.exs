defmodule APITest do
  use ExUnit.Case

  setup_all do
    {:ok, pid} = Sider.start_link
    {:ok, [client: pid]}
  end

  test "sets", ctx do
    client = ctx[:client]

    assert "1" == client |> Sider.sadd("set1", "bar")
    assert "2" == client |> Sider.sadd("set2", ["bar", "foo"])
    assert ["foo"] == client |> Sider.sdiff(["set2", "set1"])
    assert "1" == client |> Sider.sdiffstore("dest", ["set2", "set1"])
  end

end
