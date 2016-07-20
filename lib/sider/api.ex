defmodule Sider.API do

  defmacro __using__(_opts) do
    IO.inspect "OHAI!!"
    quote do
      def sadd(x, y, z) do
        IO.inspect "OHAI"
        :ok
      end
    end
  end

end
