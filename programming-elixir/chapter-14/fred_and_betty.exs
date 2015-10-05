defmodule FredAndBetty do
	def run do
		fred = spawn(FredAndBetty, :echo, [])
		betty = spawn(FredAndBetty, :echo, [])

		send(fred, {self, "fred"})
		send(betty, {self, "betty"})

		receive do
			s -> IO.puts(s)
		end

		receive do
			s -> IO.puts(s)
		end
	end

	def echo do
		receive do
			{caller, token} -> send(caller, token)
		end
	end
end
