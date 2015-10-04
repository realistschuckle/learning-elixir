defmodule Weather do
	defstruct location: "?", condition: "", temp: "", humidity: "", wind: ""

	require Record
	Record.defrecordp :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
	Record.defrecordp :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
	
	def fetch(url) do
		url
		|> get_raw_xml
		|> halt_or_xml
		|> map_to_struct
	end

	def get_raw_xml(url) do
		try do
			case HTTPoison.get(url) do
				{:ok, response} -> evaluate_response(response)
				{:error, _} = e -> e
			end
		rescue
			_ in RuntimeError -> {:error, "Bad URL"}
		catch
			:exit, e -> {:error, e}
		end
	end

	def halt_or_xml({:error, error}) do
		IO.puts("Cannot get the weather data: #{error}")
		System.halt
	end

	def halt_or_xml({:ok, raw_xml}) do
		raw_xml
		|> String.to_char_list
		|> :xmerl_scan.string
	end

	def map_to_struct({xml, []}) do
		%Weather{
			location: xquery(xml, "location"),
			condition: xquery(xml, "weather"),
			temp: xquery(xml, "temperature_string"),
			humidity: xquery(xml, "relative_humidity"),
			wind: xquery(xml, "wind_string")
		}
	end

	def to_string(weather) do
		"""
		Weather for #{weather.location}
		#{String.capitalize(weather.condition)}
		with a temperature of #{weather.temp}
		and relative humidity of #{weather.humidity}%
		with the winds #{String.downcase(weather.wind)}
		"""
	end

	defp evaluate_response(%{status_code: 200} = response) do
		{:ok, response.body}
	end

	defp evaluate_response(response) do
		{:error, response.status_code}
	end

	defp xquery(xml, node_name) do
		[xmlText(value: value)] = :xmerl_xpath.string('/current_observation/#{node_name}/text()', xml)
		List.to_string(value)
	end
end
