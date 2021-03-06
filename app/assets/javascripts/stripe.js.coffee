StripeMeta =
  card:
    createToken: (params,handler) -> Stripe.card.createToken(params,handler)
    fieldMappings:
      number:    'card_number'
      exp_month: 'expiration_month'
      exp_year:  'expiration_year'
      cvc:       'security_code'
    convertResponse: (response,data={}) ->
      result = {
        stripe_tok:       response.id
        bank_name:        response.card.brand
        last_four:        response.card.last4
        expiration_month: response.card.exp_month
        expiration_year:  response.card.exp_year
      }
      for k,v of data
        result[k] = v
      result

  _bankAccount:
    createToken: (params,handler) -> Stripe.bankAccount.createToken(params,handler)
    fieldMappings:
      country:         'country'
      currency:        'currency'
      account_number:  'account_number'
      routing_number:  'routing_number'
      account_holder_type:  'account_holder_type'
      account_holder_name:  'account_holder_name'

    convertResponse: (response,data={}) ->
      result = {
        stripe_tok:       response.id
        bank_name:        response.bank_account.bank_name
        last_four:        response.bank_account.last4
      }
      for k,v of data
        result[k] = v
      result

StripeMeta['checking'] = StripeMeta['_bankAccount']
StripeMeta['savings'] = StripeMeta['_bankAccount']

class @PaymentProvider

  @tokenize: (fields, type, $container) ->
    deferred = $.Deferred()

    Stripe.setPublishableKey($container.data("stripe-publishable-key"))
    name = fields.name
    notes = fields.notes

    fieldMappings = StripeMeta[type].fieldMappings
    createToken   = StripeMeta[type].createToken
    convertResponse = StripeMeta[type].convertResponse

    params = {}
    for stripeName, appName of fieldMappings
      params[stripeName] = fields[appName]

    createToken params, (status, response) ->
      error = response.error

      if error
        errors = [{
          param: (fieldMappings[error.param] || error.param)
          message: error.message
        }]

        deferred.reject(errors)

      else
        result = convertResponse(response, account_type: type, name: name, notes: notes)

        deferred.resolve(result)

    deferred.promise()

