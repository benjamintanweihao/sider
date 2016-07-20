defmodule DecoderTest do
  use ExUnit.Case
  alias Sider.Decoder, as: D

  test "integer" do
    assert {:ok, 8674309, ""} == D.decode(":8674309\r\n")
  end

  test "empty array" do
    assert {:ok, [], ""} == D.decode("*0\r\n")
  end

  test "short bulk string" do
    assert {:ok, "BAR", ""} == D.decode("$3\r\nBAR\r\n")
  end

  test "long bulk string" do
    assert {:ok, "BARBARBARBAR", ""} == D.decode("$12\r\nBARBARBARBAR\r\n")
  end

  test "empty string" do
    assert {:ok, "", ""} == D.decode("$0\r\n\r\n")
  end

  test "array" do
    assert {:ok, ["FOO", 42], ""} == D.decode("*2\r\n$3\r\nFOO\r\n:42\r\n")
  end

  test "simple string" do
    assert {:ok, "OK", ""} == D.decode("+OK\r\n")
  end

  test "null value" do
    assert {:ok, nil, ""} == D.decode("$-1\r\n")
  end

  test "error string" do
    assert {:ok, "Error message", ""} == D.decode("-Error message\r\n")
  end

  test "array with mixed types" do
    payload = "*4\r\n$3\r\nFOO\r\n:13\r\n*2\r\n$3\r\nBAR\r\n:42\r\n+OK\r\n"
    assert {:ok , ["FOO", 13, ["BAR", 42], "OK"], ""} == D.decode(payload)
  end

end
