defmodule HelloSocket.TcpListener do
  @moduledoc """
  Listens for messages on ip:port and delegates to `TcpHandler`.
  """

  use GenServer
  require Logger
  alias HelloSocket.TcpHandler

  # Init

  def init(options \\ []) do
    {:ok, pid} =
      :ranch.start_listener(
        __MODULE__,
        options[:pool_size],
        :ranch_tcp,
        [
          ip: options[:ip],
          port: options[:port]
        ],
        TcpHandler,
        []
      )

    {:ok, %{pid: pid, options: options}}
  end

  def start_link(options \\ []) do
    options =
      Keyword.merge(
        [
          ip: {127, 0, 0, 1},
          port: 4000,
          pool_size: 10
        ],
        options
      )

    Logger.info("#{__MODULE__}.start_link options=#{inspect(options)}")
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  # Public API

  @doc """
  Get current state
  """
  def get_state, do: GenServer.call(__MODULE__, :get_state)

  # GenServer API

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
