module FinancialOverview
  class Seller < FinancialOverview::Base
    def initialize(opts={})
      super
      @calculation_method = :seller_net_total
      @partial = "seller"

      base_order_scope = Order.orders_for_seller(@user).where(market: @market)
      @cc_ach_orders = base_order_scope.paid_with(["credit card", "ach"])
      @po_orders = base_order_scope.paid_with("purchase order")
    end

    def money_in_today
      orders = []

      orders += @cc_ach_orders.paid.delivered_between(today(offset: -7))
      orders += @po_orders.delivered.paid_between(today(offset: -7))

      sum_seller_items(orders)
    end

    def money_in_next_seven
      orders = []

      orders += @cc_ach_orders.paid.delivered_between(next_seven_days(offset: -7))
      orders += @po_orders.delivered.paid_between(next_seven_days(offset: -7))

      sum_seller_items(orders)
    end
  end
end
