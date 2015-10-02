defmodule Todo.Application do
	import Application

	def start(_, _) do
		Todo.Supervisor.start_link
	end
end
