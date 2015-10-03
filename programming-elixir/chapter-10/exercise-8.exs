defmodule TotalMaker do
	def calc(rates, orders) do
		for order <- orders, do: rate_with_total(order, rates[order[:ship_to]])
	end
	
	defp rate_with_total(order, nil) do
		[{:total_amount, order[:net_amount]} | order]
	end

	defp rate_with_total(order, rate) do
		total = round(100 * order[:net_amount] * (1 + rate)) / 100
		[{:total_amount, total} | order]
	end
end

defmodule Example do
	def run do
		TotalMaker.calc(tax_rates, orders)
	end

	defp tax_rates do
		[NC: 0.075, TX: 0.08]
	end

	defp orders do
		[
			[id: 123, ship_to: :NC, net_amount: 100.00],
			[id: 124, ship_to: :OK, net_amount:  35.50],
			[id: 125, ship_to: :TX, net_amount:  24.00],
			[id: 126, ship_to: :TX, net_amount:  44.80],
			[id: 127, ship_to: :NC, net_amount:  25.00],
			[id: 128, ship_to: :MA, net_amount:  10.00],
			[id: 129, ship_to: :CA, net_amount: 102.00],
			[id: 120, ship_to: :NC, net_amount:  50.00]
		]
	end
end
