defmodule Sider.Decoder do

  def decode(<<":", n :: binary>>) do
    decode_integer(n)
  end

  def decode(<<"*", rest :: binary>>) do
    decode_array(rest)
  end

  def decode(<<"$", rest :: binary>>) do
    decode_string(rest)
  end

  def decode(<<"+", rest :: binary>>) do
    decode_simple_string(rest)
  end

  def decode(<<"-", rest :: binary>>) do
    decode_simple_string(rest)
  end

  defp decode_integer(n) do
    case Integer.parse(n) do
      {n, <<"\r\n", rest :: binary>>} ->
        {:ok, n, rest}

      :error ->
        :error
    end
  end

  defp decode_array(binary) do
    case Integer.parse(binary) do
      {n, <<"\r\n", rest :: binary>>} ->
        take_n(rest, n, [])

      :error ->
        :error
    end
  end

  defp decode_string(binary) do
    case Integer.parse(binary) do
      {-1, <<"\r\n", rest :: binary>>} ->
        {:ok, nil, rest}

      {n, rest} when n >= 0 ->
        <<"\r\n", str :: binary-size(n), "\r\n", r :: binary>> = rest
        {:ok, str, r}

      :error ->
        :error
    end
  end

  defp decode_simple_string(binary) do
    case String.split(binary, "\r\n", parts: 2) do
      [str, rest] ->
        {:ok, str, rest}

      :error ->
        :error
    end
  end

  defp take_n(binary, 0, values) do
    {:ok, Enum.reverse(values), binary}
  end

  defp take_n(binary, n, values) do
    case decode(binary) do
      {:ok, value, rest} ->
        take_n(rest, n-1, [value|values])

      :error ->
        :error
    end
  end

end
