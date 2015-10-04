defmodule WeatherCliTest do
  use ExUnit.Case

	test "--help returns :help" do
		assert Weather.CLI.parse_args(["--help"]) === :help
	end

	test "-h returns :help" do
		assert Weather.CLI.parse_args(["-h"]) === :help
	end

	test "nothing returns :help" do
		assert Weather.CLI.parse_args([]) === :help
	end

	test "specifying a station returns the station" do
		assert Weather.CLI.parse_args(["khou"]) === "khou"
	end

	test "help_or_station returns station in uppercase for strings" do
		assert Weather.CLI.help_or_station("khou") === "KHOU"
		assert Weather.CLI.help_or_station("kIAh") === "KIAH"
	end
end
