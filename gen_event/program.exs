defmodule Monitor do
	use GenServer
	defstruct monitor: nil, start: nil, end: nil

	def content(pid) do
		GenServer.call(pid, :content)
	end
	
	def start_link(path) do
		GenServer.start_link(__MODULE__, path)
	end

	def init(path) do
		{:ok, monitor} = GenEvent.start_link([])
		GenEvent.add_handler(monitor, Start, %{path: path, caller: self})
		GenEvent.add_handler(monitor, End, %{path: path, caller: self})
		IO.puts("notifying handlers...")
		GenEvent.notify(monitor, :process)
		IO.puts("notified handlers.")
		{:ok, %Monitor{monitor: monitor}}
	end

	def handle_call(:content, _, %Monitor{start: nil} = s), do: {:reply, nil, s}
	def handle_call(:content, _, %Monitor{end: nil} = s), do: {:reply, nil, s}
	def handle_call(:content, _, %Monitor{start: start, end: content_end} = s), do: {:reply, start <> content_end, s}

	def handle_info({:start, content}, state) do
		{:noreply, %Monitor{state | start: content}}
	end

	def handle_info({:end, content}, state) do
		{:noreply, %Monitor{state | end: content}}
	end
end

defmodule Start do
	use GenEvent

	def init(%{path: path, caller: caller}) do
		IO.puts("init of start")
		case File.open(path) do
			{:ok, device} -> {:ok, %{device: device, caller: caller}}
			e -> e
		end
	end

	def handle_event(:process, %{device: device, caller: caller}) do
		:timer.sleep(:random.uniform(800))
		IO.puts("got the process event in start")
		content =
			device
		  |> IO.binread(10)
		send(caller, {:start, content})
		:remove_handler
	end

	def terminate(_, %{device: device}) do
		IO.puts("closing start file...")
		File.close(device)
	end
end

defmodule End do
	use GenEvent

	def init(%{path: path, caller: caller}) do
		IO.puts("init of end")
		case File.open(path) do
			{:ok, device} -> {:ok, %{device: device, caller: caller}}
			e -> e
		end
	end

	def handle_event(:process, %{device: device, caller: caller}) do
		:timer.sleep(:random.uniform(500))
		IO.puts("got the process event in end")
		:file.position(device, {:eof, -10})
		content =
			device
		  |> IO.binread(10)
		send(caller, {:end, content})
		:remove_handler
	end

	def terminate(_, %{device: device}) do
		IO.puts("closing end file...")
		File.close(device)
	end
end

:random.seed(:erlang.timestamp)
{:ok, pid} = Monitor.start_link("program.exs")
IO.puts(Monitor.content(pid) || "no response...")
:timer.sleep(1000)
IO.puts(Monitor.content(pid))
