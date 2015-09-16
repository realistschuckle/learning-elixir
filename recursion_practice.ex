defmodule RecursionPractice do
	def list_len(list) do
		list_len_accumulator(0, list)
	end

	defp list_len_accumulator(len, []) do
		len
	end

	defp list_len_accumulator(len, [ _ | tail ]) do
		list_len_accumulator(len + 1, tail)
	end
	

	def range(from, to) when from <= to do
		range_accumulator(from, to)
	end

	defp range_accumulator(to, to) do
		[ to ]
	end

	defp range_accumulator(from, to) do
		[ from | range_accumulator(from + 1, to) ]
	end

	def positive([]) do
		[]
	end

	def positive([ head | tail ]) when head > 0 do
		[ head | positive(tail) ]
	end

	def positive([ _ | tail ]) do
		positive(tail)
	end
end
