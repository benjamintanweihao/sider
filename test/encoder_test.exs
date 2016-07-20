defmodule EncoderTest do
  use ExUnit.Case
  alias Sider.Encoder, as: E

  test "encode" do
    expected = "*3\r\n$3\r\nSET\r\n$3\r\nFOO\r\n$3\r\nBAR\r\n"
    assert expected == E.encode(["SET", "FOO", "BAR"])
  end

end
