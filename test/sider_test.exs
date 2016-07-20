defmodule SiderTest do
  use ExUnit.Case

  setup_all do
    {:ok, pid} = Sider.start_link
    {:ok, [client: pid]}
  end

  test "smoke" do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 6379, opts)
    :ok = :gen_tcp.send(socket, "LOLWUT\r\n")
    {:ok, msg} = :gen_tcp.recv(socket, 0)

    assert "-ERR unknown command 'LOLWUT'\r\n" == msg
  end

  test "start_link" do
    {:ok, pid} = Sider.start_link

    assert is_pid(pid)
  end

  test "stop" do
    {:ok, pid} = Sider.start_link
    :ok = Sider.stop(pid)

    refute Process.alive?(pid)
  end

  test "query", ctx do
    client = ctx[:client]

    client |> Sider.query(["SET", "FOO", "BAR"])

    assert "BAR" == client |> Sider.query(["GET", "FOO"])
  end
end
