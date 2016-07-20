defmodule Sider do
  use GenServer
  alias Sider.Encoder
  alias Sider.Decoder

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
    GenServer.call(pid, {:query, Encoder.encode(args)})
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

  def handle_call({:query, payload}, _from, %State{socket: socket} = state) do
    :ok               = :gen_tcp.send(socket, payload)
    {:ok, msg}        = :gen_tcp.recv(socket, 0)
    {:ok, decoded, _} = Decoder.decode(msg)

    {:reply, decoded, state}
  end

end
