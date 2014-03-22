#= require ./validators

class Batman.LengthValidator extends Batman.Validator
    @triggers 'minLength', 'maxLength', 'length', 'lengthWithin', 'lengthIn'
    @options 'allowBlank'
    constructor: (options) ->
      if range = (options.lengthIn or options.lengthWithin)
        options.minLength = range[0]
        options.maxLength = range[1] || -1
        delete options.lengthWithin
        delete options.lengthIn

      super

    validateEach: (errors, record, key, callback) ->
      options = @options
      value = record.get(key)
      return callback() if @handleBlank(value)
      value ?= []
      if options.minLength and value.length < options.minLength
        messageSymbol = 'too_short'
        count = options.minLength
      if options.maxLength and value.length > options.maxLength
        messageSymbol = 'too_long'
        count = options.maxLength
      if options.length and value.length isnt options.length
        messageSymbol = 'wrong_length'
        count = options.length
      if messageSymbol?
        errors.add key, messageSymbol, Batman.mixin({interpolations: {count}}, @options)
      callback()

Batman.Validators.push Batman.LengthValidator
