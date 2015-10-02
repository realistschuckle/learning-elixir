defmodule MyEnum do
	def all?(list, fun \\ fn(x) -> x end), do: do_all?(list, fun, true)

	def each(list, fun), do: do_each(list, fun)
	
	def filter(list, fun), do: do_filter(list, fun, [], nil, false) |> reverse([])

	def split(list, count), do: do_split(list, count, [], 0)

	def take(list, count), do: do_take(list, count, [], 0) |> reverse([])

	defp do_all?([], _, value), do: value
	defp do_all?([h | t], fun, acc), do: do_all?(t, fun, (!!fun.(h)) and acc)

	defp do_each([], _), do: :ok
	defp do_each([h | t], fun) do
		fun.(h)
		do_each(t, fun)
	end

	defp do_filter([], _, acc, value, true), do: [value | acc]
	defp do_filter([], _, acc, _, false), do: acc
	defp do_filter([h | t], fun, acc, _, false), do:	do_filter(t, fun, acc, h, fun.(h))
	defp do_filter([h | t], fun, acc, value, true), do: do_filter(t, fun, [value | acc], h, fun.(h))

	defp do_split(list, count, acc, count), do: {reverse(acc, []), list}
	defp do_split(list, count, acc, index) when count < 0, do: do_split(list, len(list) + count, acc, index)
	defp do_split([h | t], count, acc, index), do: do_split(t, count, [h | acc], index + 1)

	defp do_take([], _, acc, _), do: acc
	defp do_take(_, count, acc, count), do: acc
	defp do_take(list, count, acc, index) when count < 0, do: do_split(list, len(list) + count, acc, index) |> elem(1) |> reverse([])
	defp do_take([h | t], count, acc, index), do: do_take(t, count, [h | acc], index + 1)

	defp len([]), do: 0
	defp len([_ | t]), do: 1 + length(t)

	defp reverse([], acc), do: acc
	defp reverse([h | t], acc), do: reverse(t, [h | acc])
end
