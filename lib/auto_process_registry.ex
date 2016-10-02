defmodule AutoProcessRegistry do
	@moduledoc """
	AutoProcessRegistry is a process registry that is setup with a
	starter function to start new processes on demand.

	Processes aren't supervised. The idea is that if they die, for
	whichever reason, they can be restarted on demand when necessary. It
  is not hard, though, to make the starter function register a process
  under a supervisor.

	The registry complies with 'via' naming.

  Moar docs needed.
	"""

	@doc """
	Start the GenServer process implementing the registry. The `starter_fun`
	argument is a function that takes a key and returns a tuple with
	status and the new process id. It is called whenever `send/3` is called
	for a key that doesn't have a corresponding process.
	"""
	@callback start_link :: GenServer.on_start

  @callback start_new(any) :: GenServer.on_start

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour AutoProcessRegistry

			use GenServer

			# Client API

			@doc false
			def start_link do
				GenServer.start_link(__MODULE__, [], name: __MODULE__)
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

			def init([]) do
				{:ok, %{}}
			end

			def handle_call({:create_new, key}, _from, registry) do
				case Map.get(registry, key, nil) do
					nil ->
						{:ok, pid} = start_new(key)
						Process.monitor(pid)
						registry = Map.put(registry, key, pid)
						{:reply, {:ok, pid}, registry}

					pid ->
						{:reply, {:ok, pid}, registry}
				end
			end

			def handle_call({:whereis_name, key}, _from, registry) do
				case Map.get(registry, key, nil) do
					nil ->
						{:ok, pid} = start_new(key)
						Process.monitor(pid)
						registry = Map.put(registry, key, pid)
						{:reply, pid, registry}

					pid ->
						{:reply, pid, registry}
				end
			end

			def handle_info({:DOWN, _ref, :process, pid, _reason}, registry) do
				{:noreply, deregister(registry, pid)}
			end

			def handle_info(_info, registry), do: {:noreply, registry}

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
