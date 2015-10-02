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
		:ets.new(:process_registry, [:set, :named_table, :protected])
		{:ok, nil}
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

	def handle_call({:register_name, key, pid}, _, state) do
		case :ets.lookup(:process_registry, key) do
			[{^key, pid}] -> {:reply, :no, state}
			_ ->
				Process.monitor(pid)
				:ets.insert(:process_registry, {key, pid})
				{:reply, :yes, state}
		end
	end

	def handle_call({:whereis_name, key}, _, state) do
		case :ets.lookup(:process_registry, key) do
			[{^key, pid}] -> {:reply, pid, state}
			_ -> {:reply, :undefined, state}
		end
	end

	def handle_call({:unregister_name, key}, _, state) do
		:ets.delete(:process_registry, key)
		{:reply, key, state}
	end

	def handle_info({:DOWN, _, :process, pid, _}, state) do
		deregister_pid(pid)
		{:noreply, state}
	end

	def handle_info(_, state), do: {:noreply, state}

	defp deregister_pid(pid) do
		case :ets.match_object(:process_registry, {:_, pid}) do
			[{key, _}] -> :ets.delete(:process_registry, key)
			_ -> nil
		end
	end
end
