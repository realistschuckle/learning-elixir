defmodule Chop do
	def guess(actual, lower..upper) do
		guess = div(upper + lower, 2)
		IO.puts("Is it #{guess}?")
		resolve(actual, guess, lower..upper)
	end

	defp resolve(value, value, _) do
		IO.puts(value)
	end

	defp resolve(actual, guess, _..upper) when guess < actual do
		guess(actual, guess + 1..upper)
	end
	
	defp resolve(actual, guess, lower.._) do
		guess(actual, lower..guess - 1)
	end
end
