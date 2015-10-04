import Kernel, except: [to_string: 1]

defimpl String.Chars, for: Weather do
	def to_string(nil), do: ""
	def to_string(%Weather{} = weather), do: Weather.to_string(weather)
end

	
