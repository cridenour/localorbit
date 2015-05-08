module PaymentProvider
  Implementations = {
    stripe: PaymentProvider::Stripe,
    balanced: PaymentProvider::Balanced
  }

  class << self

    def for(payment_provider)
      raise "No PaymentProvider... payment_provider can't be nil" if payment_provider.nil?
      impl = Implementations[payment_provider.to_sym]
      return impl if impl
      raise "No PaymentProvider for #{payment_provider.inspect}"
    end

    def is_balanced?(payment_provider)
      return false if payment_provider.nil?
      PaymentProvider::Balanced.id == payment_provider.to_sym
    end

    def supports_payment_method?(payment_provider, payment_method)
      PaymentProvider.for(payment_provider).supported_payment_methods.include?(payment_method)
    end
    
    #
    # Common PaymentProvide interface: 
    # 
    
    def place_order(payment_provider, buyer_organization:, user:, order_params:, cart:)
      PaymentProvider.for(payment_provider).place_order( 
        buyer_organization: buyer_organization,
        user: user,
        order_params: order_params,
        cart: cart)
    end

    def translate_status(payment_provider, charge:, amount:nil, payment_method:nil)
      PaymentProvider.for(payment_provider).translate_status(
        charge: charge,
        amount: amount,
        payment_method: payment_method)
    end

    def charge_for_order(payment_provider, amount:, bank_account:, market:, order:, buyer_organization:)
      PaymentProvider.for(payment_provider).charge_for_order(
                          amount: amount,
                          bank_account: bank_account,
                          market: market,
                          order: order,
                          buyer_organization: buyer_organization)

    end

    def fully_refund(payment_provider, charge: nil, payment:, order:)
      PaymentProvider.for(payment_provider).fully_refund(
        charge: charge,
        payment: payment,
        order: order)
    end

    def store_payment_fees(payment_provider, order:)
      PaymentProvider.for(payment_provider).store_payment_fees(
        order: order)
    end

    def create_order_payment(payment_provider, charge:, market_id:, bank_account:, payer:,
                             payment_method:, amount:, order:, status:)
      PaymentProvider.for(payment_provider).create_order_payment(
        charge: charge,
        market_id: market_id,
        bank_account: bank_account,
        payer: payer,
        payment_method: payment_method,
        amount: amount,
        order: order,
        status: status)
    end

    def create_refund_payment(payment_provider, charge:, market_id:, bank_account:, payer:,
                                  payment_method:, amount:, order:, status:, refund:, parent_payment:)
      PaymentProvider.for(payment_provider).create_refund_payment(
        charge: charge,
        market_id: market_id,
        bank_account: bank_account,
        payer: payer,
        payment_method: payment_method,
        amount: amount,
        order: order,
        status: status,
        refund: refund,
        parent_payment: parent_payment)
    end
  end
end
