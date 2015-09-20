defmodule Calculator do
	def add(calculator_pid, value), do: send(calculator_pid, {:add, value})
	def div(calculator_pid, value), do: send(calculator_pid, {:div, value})
	def mul(calculator_pid, value), do: send(calculator_pid, {:mul, value})
	def sub(calculator_pid, value), do: send(calculator_pid, {:sub, value})

	def start do
		spawn(fn -> loop(0) end)
	end

	def value(calculator_pid) do
		send(calculator_pid, {:value, self})
		receive do
			{:response, current_value} -> current_value
		after 5000 -> {:error, :timeout}
		end
	end

	defp loop(current_value) do
		new_value = receive do
			{:value, caller} ->
				send(caller, {:response, current_value})
				current_value
			{:add, value} -> current_value + value
			{:sub, value} -> current_value - value
			{:mul, value} -> current_value * value
			{:div, value} -> current_value / value

			invalid_request ->
				IO.puts("invalid request #{inspect(invalid_request)}")
				current_value
		end

		loop(new_value)
	end
end
