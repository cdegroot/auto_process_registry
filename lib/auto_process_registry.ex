defmodule AutoProcessRegistry do
	@moduledoc """
	AutoProcessRegistry is a process registry that is setup with a
	starter function to start new processes on demand.

	Processes aren't supervised. The idea is that if they die, for
	whichever reason, they can be restarted on demand when necessary. It
  is not hard, though, to make the starter function register a process
  under a supervisor.
	"""
  use GenServer

  # Client API

	@doc """
	Start the GenServer process implementing the registry. The `starter_fun`
  argument is a function that takes a key and returns a tuple with
  status and the new process id. It is called whenever `send/3` is called
  for a key that doesn't have a corresponding process.
  """
	@spec start_link((any -> GenServer.on_start)) :: GenServer.on_start
  def start_link(starter_fun) do
    GenServer.start_link(__MODULE__, starter_fun)
  end

  @doc """
  Send a message to the process that is associated with the given key.
  """
  @spec send(pid, any, any) :: any
  def send(registry_pid, key, msg) do
    target_pid = case whereis_name(registry_pid, key) do
      pid when is_pid(pid) ->
        pid

      :undefined ->
				{:ok, pid} = GenServer.call(registry_pid, {:create_new, key})
				pid
    end
		Kernel.send(target_pid, msg)
  end

  defp whereis_name(registry_pid, key) do
    GenServer.call(registry_pid, {:whereis_name, key})
  end

  # Server API #

  def init(starter_fun) do
    {:ok, {starter_fun, %{}}}
  end

  def handle_call({:create_new, key}, _from, {starter_fun, registry}) do
    case Map.get(registry, key, nil) do
      nil ->
				{:ok, pid} = starter_fun.(key)
        Process.monitor(pid)
        registry = Map.put(registry, key, pid)
				{:reply, {:ok, pid}, {starter_fun, registry}}

      pid ->
				{:reply, {:ok, pid}, {starter_fun, registry}}
    end
  end

  def handle_call({:whereis_name, key}, _from, registry) do
    {:reply, Map.get(registry, key, :undefined), registry}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, {starter_fun, registry}) do
    {:noreply, {starter_fun, deregister(registry, pid)}}
  end

  def handle_info(_info, {starter_fun, registry}), do: {:noreply, {starter_fun, registry}}

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
