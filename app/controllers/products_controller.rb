class ProductsController < ApplicationController
  before_action :require_current_organization
  before_action :require_organization_location
  before_action :require_current_delivery
  before_action :require_cart
  before_action :hide_admin_navigation

  def index
    products = Product.available_for_sale(current_market, current_organization)
    # TODO: Optimize this lookup. It just got much more expensive
    @categories = Category.where(depth: 2)
    @product_groups = products.periscope(request.query_parameters).decorate( context: {current_cart: current_cart}).group_by{|p| p.category.self_and_ancestors.find_by(depth: 2) }
    @filter_categories = Category.where(id: products.pluck(:top_level_category_id).uniq)
  end
end
