defmodule HelloSocket.TcpHandler do
  @moduledoc """
  Handle messages from `TcpListener`.
  """

  use GenServer
  require Logger

  @behaviour :ranch_protocol

  defmodule State do
    defstruct [
      :id,
      :peername,
      :ref,
      :socket,
      :transport
    ]
  end

  # Init

  def init(%{ref: ref, socket: socket, transport: transport} = args) do
    :ok = :ranch.accept_ack(ref)

    :ok =
      transport.setopts(socket, [
        {:active, :once},
        {:packet, 4},
        {:reuseaddr, true}
      ])

    :gen_server.enter_loop(__MODULE__, [], struct!(State, args))
  end

  def start_link(ref, socket, transport, _args) do
    pid =
      :proc_lib.spawn_link(__MODULE__, :init, [
        %{
          id: System.pid(),
          peername: get_peername(socket),
          ref: ref,
          socket: socket,
          transport: transport
        }
      ])

    {:ok, pid}
  end

  # GenServer API

  def handle_info({:tcp, socket, packet}, %State{} = state) do
    Logger.info("message=#{inspect(packet)}")

    :gen_tcp.send(socket, "ack! id=#{state.id}")
    :gen_tcp.close(socket)

    {:stop, :normal, :ok}
  end

  # Private

  defp get_peername(socket) do
    case :inet.peername(socket) do
      {:ok, {address, port}} ->
        address
        |> :inet_parse.ntoa()
        |> to_string()
        |> Kernel.<>(":#{port}")

      {:error, :einval} ->
        "unknown"
    end
  end
end
