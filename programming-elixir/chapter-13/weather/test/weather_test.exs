defmodule WeatherTest do
  use ExUnit.Case

	test "get_xml returns {:ok, raw_xml} for a 200 HTTP response" do
		assert {:ok, _} = Weather.get_xml("http://w1.weather.gov/xml/current_obs/KDTO.xml")
	end

	test "get_xml returns {:error, error} for bad non-200 HTTP responses" do
		assert {:error, _} = Weather.get_xml("http://w1.weather.gov/xml/current_obs/NOPE_NOT_HERE.xml")
	end

	test "get_xml returns {:error, error} for a bad fetch" do
		assert {:error, _} = Weather.get_xml("bad argument")
	end
end
