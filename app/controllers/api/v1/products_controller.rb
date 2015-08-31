module Api
  module V1
    class ProductsController < ApplicationController
      include ActiveSupport::NumberHelper
      before_action :require_selected_market
      before_action :require_market_open
      before_action :require_current_organization
      before_action :require_organization_location
      before_action :require_current_delivery

      def index
        @offset = (params[:offset] || 0).to_i
        @limit = (params[:limit] || 10).to_i
        @query = (params[:query] || '').gsub(/\W+/, '+') || ''
        @category_ids = (params[:category_ids] || [])
        @seller_ids = (params[:seller_ids] || [])
        render :json => {products: products, product_total: available_products.count(:all)}
      end

      def products
        output = available_products
          .offset(@offset)
          .limit(@limit)
        output.map {|p| output_hash(p)}
      end

      private

      def available_products
        available_products = current_delivery
          .object
          .delivery_schedule
          .products
          .includes(:organization, :second_level_category, :prices, :unit)
          .with_available_inventory(current_delivery.deliver_on)
          .priced_for_market_and_buyer(current_market, current_organization)
        available_products = apply_filters(available_products)
        available_products.order(:name).uniq
      end

      def apply_filters(available_products)
        if(@query.length > 2)
          available_products = available_products.search_by_text(@query)
        end
        if(@category_ids.length > 0 && @seller_ids.length > 0)
          available_products = available_products.where("
          (
            products.category_id IN (?)
            OR products.top_level_category_id IN (?)
            OR products.second_level_category_id in (?)
            OR products.organization_id in (?)
          )", @category_ids, @category_ids, @category_ids, @seller_ids)
        elsif(@category_ids.length > 0)
          available_products = available_products.where("
          (
            products.category_id IN (?)
            OR products.top_level_category_id IN (?)
            OR products.second_level_category_id in (?)
          )", @category_ids, @category_ids, @category_ids)
        elsif(@seller_ids.length > 0)
          available_products = available_products.where(organization: @seller_ids)
        end
        available_products
      end

      def output_hash(product)
        product = product.decorate(context: {current_cart: current_cart})
        {
          :id=> product.id,
          :name=> product.name,
          :second_level_category_name => product.second_level_category.name,
          :seller_name => product.organization.name,
          :seller_id => product.organization.id,
          :short_description => product.short_description,
          :long_description => product.long_description,
          :cart_item => product.cart_item,
          :cart_item_quantity => product.cart_item.quantity,
          :max_available => product.available_inventory(current_delivery.deliver_on),
          :price_for_quantity => number_to_currency(product.cart_item.unit_price.sale_price),
          :total_price => product.cart_item.decorate.display_total_price,
          :cart_item_persisted => product.cart_item.persisted?,
          :image_url => get_image_url(product.object),
          :who_story => product.organization.who_story,
          :how_story => product.organization.how_story,
          :location_label => product.location_label,
          :location_map_url => product.location_map(310, 225),
          :unit => product.unit.plural,
          :prices => product.prices_for_market_and_organization(current_market, current_organization).map {|price| format_price(price) }
        }
      end

      def get_image_url(product)
        if(product.thumb_stored?)
          view_context.image_url(product.thumb.url)
        elsif product.image_stored?
          view_context.image_url(product.image.thumb("150x150").url)
        else
          view_context.image_url('default-product-image.png')
        end
      end

      def format_price(price)
        price = price.decorate
        {
          :sale_price => number_to_currency(price.sale_price),
          :min_quantity => price.min_quantity
        }
      end
    end
  end
end