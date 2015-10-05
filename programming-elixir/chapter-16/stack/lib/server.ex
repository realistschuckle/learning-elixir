defmodule Stack.Server do
	use GenServer

	def handle_call(:pop, _, [head | tail]) do
		{:reply, head, tail}
	end

	def handle_cast({:push, value}, list) do
		{:noreply, [value | list]}
	end
end
