defmodule Todo.ProcessRegistry do
	use GenServer
	import Kernel, except: [send: 2]

	def register_name(key, pid) do
		GenServer.call(:todo_process_registry, {:register_name, key, pid})
	end

	def whereis_name(key) do
		GenServer.call(:todo_process_registry, {:whereis_name, key})
	end

	def unregister_name(key) do
		GenServer.cast(:todo_process_registry, {:unregister_name, key})
	end

	def start_link do
		GenServer.start_link(__MODULE__, nil, name: :todo_process_registry)
	end

	def init(_) do
		IO.puts("Starting process registry.")
		{:ok, HashDict.new}
	end

	def send(key, message) do
		IO.puts("Process registry received #{key}, #{message}")
		case whereis_name(key) do
			:undefined -> {:badarg, {key, message}}
			pid ->
				Kernel.send(pid, message)
				pid
		end
	end

	def handle_call({:register_name, key, pid}, _, registry) do
		case HashDict.get(registry, key) do
			nil ->
				Process.monitor(pid)
				{:reply, :yes, HashDict.put(registry, key, pid)}
			_ ->
				{:reply, :no, registry}
		end
	end

	def handle_call({:whereis_name, key}, _, registry) do
		{:reply, HashDict.get(registry, key, :undefined), registry}
	end

	def handle_call({:unregister_name, key}, _, registry) do
		{:reply, key, HashDict.delete(registry, key)}
	end

	def handle_info({:DOWN, _, :process, pid, _}, registry) do
		{:noreply, deregister_pid(registry, pid)}
	end

	def handle_info(_, state), do: {:noreply, state}

	defp deregister_pid(registry, pid) do
		Enum.reduce(
			registry,
			registry,
			fn
				({ralias, rprocess}, racc) when rprocess == pid ->
					HashDict.delete(racc, ralias)
				(_, racc) -> racc
			end
		)
	end
end
