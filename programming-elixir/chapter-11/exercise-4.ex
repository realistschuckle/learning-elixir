defmodule MyCalculator do
	def calculate(chars), do: do_calculate(chars, nil, nil, nil)

	defp do_calculate([], a, b, ?+), do: a + b
	defp do_calculate([], a, b, ?-), do: a - b
	defp do_calculate([], a, b, ?/), do: a / b
	defp do_calculate([], a, b, ?*), do: a * b

	defp do_calculate([?\s | t], a, b,   op),  do: do_calculate(t, a, b, op)
	defp do_calculate([?+  | t], a, nil, nil), do: do_calculate(t, a, nil, ?+)
	defp do_calculate([?-  | t], a, nil, nil), do: do_calculate(t, a, nil, ?-)
	defp do_calculate([?/  | t], a, nil, nil), do: do_calculate(t, a, nil, ?/)
	defp do_calculate([?*  | t], a, nil, nil), do: do_calculate(t, a, nil, ?*)

	defp do_calculate([h | t], nil, nil, nil), do: do_calculate(t, bump(0, h), nil, nil)
	defp do_calculate([h | t], a,   nil, nil), do: do_calculate(t, bump(a, h), nil, nil)
	defp do_calculate([h | t], a,   nil, op),  do: do_calculate(t, a, bump(0, h), op)
	defp do_calculate([h | t], a,   b,   op),  do: do_calculate(t, a, bump(b, h), op)

	defp bump(a, b), do: (a * 10) + (b - ?0)
end
