defmodule CliTest do
	use ExUnit.Case

	import Issues.CLI, only: [parse_args: 1]

	test ":help returned by option parsing with -h and --help options" do
		assert parse_args(["--help", "more"]) === :help
		assert parse_args(["-h",     "more"]) === :help
	end

	test "three values returned if three given" do
		assert parse_args(["user", "project", "99"]) === {"user", "project", 99}
	end

	test "two values returns two values and default count" do
		assert parse_args(["user", "project"]) === {"user", "project", 4}
	end
end
