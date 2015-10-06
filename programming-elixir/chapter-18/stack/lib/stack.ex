defmodule Stack do
	use Application

	def start(_, _) do
		Stack.MainSupervisor.start_link
	end
end
