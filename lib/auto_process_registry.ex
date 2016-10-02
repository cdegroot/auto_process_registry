defmodule AutoProcessRegistry do
  @moduledoc """
  AutoProcessRegistry is a process registry that is setup with a
  starter function to start new processes on demand.

  Processes aren't supervised. The idea is that if they die, for
  whichever reason, they can be restarted on demand when necessary. It
  is not hard, though, to make the starter function register a process
  under a supervisor.

  The registry implements the `whereis` message that is needed to
  make it usable for via naming lookups in the style of
  `{:via, YourRegistryModule, key}`.

  Moar docs needed. I would also say moar config needed - an argument
  to start_link that is passed to start_new.
  """

  @doc """
  Start the GenServer process implementing the registry. The GenServer
  is registered with the module name, so keeping the pid around is not
  necessary. The config argument is passed on to `start_new`
  """
  @callback start_link(any) :: GenServer.on_start

  @doc """
  Start a new process with the config argument as the first argument
  and the key as the second argument.
  """
  @callback start_new(any, any) :: GenServer.on_start

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour AutoProcessRegistry

      use GenServer

      # Client API

      @doc false
      def start_link(config) do
        GenServer.start_link(__MODULE__, config, name: __MODULE__)
      end

      def send(key, msg) do
        case whereis_name(key) do
          pid when is_pid(pid) ->
            Kernel.send(pid, msg)

          :undefined ->
            {:badarg, {key, msg}}
        end
      end

      def whereis_name(key) do
        GenServer.call(__MODULE__, {:whereis_name, key})
      end

      # Server API #

      def init(config) do
        {:ok, {config, %{}}}
      end

      def handle_call({:whereis_name, key}, _from, {config, registry}) do
        case Map.get(registry, key, nil) do
          nil ->
            {:ok, pid} = start_new(config, key)
            Process.monitor(pid)
            registry = Map.put(registry, key, pid)
            {:reply, pid, {config, registry}}

          pid ->
            {:reply, pid, {config, registry}}
        end
      end

      def handle_info({:DOWN, _ref, :process, pid, _reason}, {config, registry}) do
        {:noreply, {config, deregister(registry, pid)}}
      end

      def handle_info(_info, state), do: {:noreply, state}

      # Helper Functions #
      defp deregister(registry, pid) when is_pid(pid) do
        case Enum.find(registry, nil, fn({_key, cur_pid}) -> cur_pid == pid end) do
          nil -> registry
          {key, _pid} -> deregister(registry, key)
        end
      end

      defp deregister(registry, key) do
        Map.delete(registry, key)
      end
    end
  end
end
