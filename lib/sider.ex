defmodule Sider do
  use GenServer

  defmodule State do
    defstruct socket: nil
  end

  #######
  # API #
  #######

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def query(pid, args) do
    :ok
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  #############
  # Callbacks #
  #############

  def init(:ok) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 6379, opts)
    {:ok, %State{socket: socket}}
  end

end
