module Metrics
  class ProductCalculations < Base
    BASE_SCOPE = Product.joins(organization: :markets).where.not(organization_id: TEST_ORG_IDS).uniq
    METRICS = {
      total_products: {
        title: "Total Products",
        scope: Product,
        calculation: :metric,
        format: :integer
      },
      total_products_simple: {
        title: "Total Products Using Simple Inventory",
        scope: BASE_SCOPE,
        calculation: :metric,
        format: :integer
      },
      total_products_advanced: {
        title: "Total Products Using Advanced Inventory",
        scope: BASE_SCOPE,
        calculation: :metric,
        format: :integer
      },
      total_products_ordered: {
        title: "Total Products Ordered",
        scope: BASE_SCOPE.joins(:orders),
        attribute: "orders.placed_at",
        calculation: :count,
        calculation_arg: "products.id",
        format: :integer
      },
      average_product_price: {
        title: "Average Product Price",
        scope: BASE_SCOPE.joins(:prices),
        attribute: :placed_at,
        calculation: :custom,
        calculation_arg: "(COUNT(DISTINCT products.id)::NUMERIC / AVERAGE(price.sale_price)::NUMERIC)",
        format: :decimal
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::ProductCalculations::METRICS)
