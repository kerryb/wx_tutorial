defmodule WxObject do
  @moduledoc """
  An incomplete Elixir wrapper for Erlang’s `:wx_object` behaviour, in the
  style of `GenServer` etc.
  """

  import WxEx.Records

  defmacro __using__(opts \\ []) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour WxObject

      def child_spec(init_arg) do
        default = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init_arg]}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end

      defoverridable child_spec: 1
    end
  end

  @callback init(args :: term()) ::
              {record(:wx_ref, ref: term(), type: term(), state: term()), state: term()}
              | {record(:wx_ref, ref: term(), type: term(), state: term()), state :: term(), timeout() | :hibernate}
              | {:stop, reason :: term()}
              | :ignore

  @callback handle_call(request :: term(), from :: GenServer.server(), state :: term()) ::
              {:reply, reply, new_state}
              | {:reply, reply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason, reply, new_state}
              | {:stop, reason, new_state}
            when reply: term(), new_state: term(), reason: term()

  @callback handle_cast(request :: term(), state :: term()) ::
              {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason :: term(), new_state}
            when new_state: term()

  @callback handle_info(msg :: :timeout | term(), state :: term()) ::
              {:noreply, new_state}
              | {:noreply, new_state, timeout | :hibernate | {:continue, continue_arg :: term()}}
              | {:stop, reason :: term(), new_state}
            when new_state: term()

  @callback handle_event(
              request :: record(:wx, id: integer(), obj: :wx.wx_object(), userData: term(), event: :wx_object.event()),
              state :: term()
            ) ::
              {:noreply, new_state :: term()}
              | {:noreply, new_state :: term(), timeout() | :hibernate}
              | {:stop, reason :: term(), new_state :: term()}

  @callback handle_sync_event(
              request :: record(:wx, id: integer(), obj: :wx.wx_object(), userData: term(), event: :wx_object.event()),
              ref :: record(:wx_ref, ref: term(), type: term(), state: term()),
              state :: term()
            ) :: :ok

  @callback terminate(reason, state :: term()) :: term()
            when reason: :normal | :shutdown | {:shutdown, term()} | term()

  @optional_callbacks terminate: 2,
                      handle_event: 2,
                      handle_call: 3,
                      handle_info: 2,
                      handle_cast: 2,
                      handle_sync_event: 3

  def start_link(module, args, options \\ []) do
    case options[:name] do
      nil -> :wx_object.start_link(module, args, options)
      name when is_atom(name) -> :wx_object.start_link({:local, name}, module, args, Keyword.delete(options, :name))
    end
  end

  defdelegate call(server, msg), to: :wx_object
  defdelegate cast(server, msg), to: :wx_object
  defdelegate stop(server, reason \\ :normal, timeout \\ :infinity), to: :wx_object
  defdelegate get_pid(ref), to: :wx_object
end
