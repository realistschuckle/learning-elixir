defmodule Monitor do
	use GenServer
	defstruct start: nil, end: nil

	def content(pid) do
		GenServer.call(pid, :content)
	end
	
	def start_link(path) do
		GenServer.start_link(__MODULE__, path)
	end

	def init(path) do
		task(Start, path)
		task(End, path)
		{:ok, %Monitor{}}
	end

	def handle_call(:content, _, %Monitor{start: nil} = s), do: {:reply, nil, s}
	def handle_call(:content, _, %Monitor{end: nil} = s), do: {:reply, nil, s}
	def handle_call(:content, _, %Monitor{start: start, end: content_end} = s), do: {:reply, start <> content_end, s}
	
	def handle_info({:error, _, :enoent}, state), do: {:stop, {:error, :enoent}, nil}
	def handle_info({:error, :start, _}, state), do: {:noreply, %Monitor{state | start: ""}}
	def handle_info({:error, :end, _}, state), do: {:noreply, %Monitor{state | end: ""}}

	def handle_info({:start, content}, state) do
		{:noreply, %Monitor{state | start: content}}
	end

	def handle_info({:end, content}, state) do
		{:noreply, %Monitor{state | end: content}}
	end

	defp task(module, path) do
		Task.start(module, :parse, [%{path: path, caller: self}])
	end
end

defmodule Start do
	def parse(%{path: path, caller: caller}) do
		case File.open(path) do
			{:ok, device} -> device |> do_parse |> send_to(caller) |> File.close
			e -> e |> inform_error(caller)
		end
	end

	defp do_parse(device) do
		{device, device |> IO.binread(10)}
	end

	defp send_to({device, content}, caller) do
		send(caller, {:start, content})
		device
	end

	defp inform_error(e, caller) do
		send(caller, {:error, :start, e})
	end
end

defmodule End do
	def parse(%{path: path, caller: caller}) do
		case File.open(path) do
			{:ok, device} -> device |> do_parse |> send_to(caller) |> File.close
			e -> e |> inform_error(caller)
		end
	end

	defp do_parse(device) do
		:file.position(device, {:eof, -10})
		{device, device |> IO.binread(10)}
	end

	defp send_to({device, content}, caller) do
		send(caller, {:end, content})
		device
	end

	defp inform_error({:error, e}, caller) do
		send(caller, {:error, :end, e})
	end
end

{:ok, pid} = Monitor.start_link("program1.exs")
IO.puts(Monitor.content(pid) || "no response...")
:timer.sleep(1000)
IO.puts(Monitor.content(pid))
