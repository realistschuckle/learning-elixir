fb = fn
	(0, 0, _) -> "FizzBuzz"
	(0, _, _) -> "Fizz"
	(_, 0, _) -> "Buzz"
	(_, _, a) -> a
end

IO.puts(fb.(0, 0, 3))
IO.puts(fb.(0, 1, 3))
IO.puts(fb.(2, 0, 3))
IO.puts(fb.(2, 1, 3))
