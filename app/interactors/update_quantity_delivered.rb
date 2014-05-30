class UpdateQuantityDelivered
  include Interactor

  def perform
    context[:previous_delivery_quantities] = order.items.map {|item| {id: item.id, quantity_delivered: item.quantity_delivered} }
    fail! unless order.update(order_params)
  end

  def rollback
    order.update(items_attributes: context[:previous_delivery_quantities])
  end
end
