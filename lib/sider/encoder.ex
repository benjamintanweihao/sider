defmodule Sider.Encoder do
  @moduledoc """
  Encodes all commands to REDIS as an Array of Bulk Strings
  """

  @doc """
  Encode args to an array of bulk strings
  """

  def encode(args) when is_list(args) do
    "*#{length(args)}\r\n" <> Enum.map_join(args, &(encode(&1)))
  end

  def encode(arg) do
    str = "#{arg}"
    "$#{String.length(str)}\r\n#{str}\r\n"
  end

end
