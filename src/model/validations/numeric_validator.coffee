#= require ./validators

class Batman.NumericValidator extends Batman.Validator
  @triggers 'numeric', 'greaterThan', 'greaterThanOrEqualTo', 'equalTo', 'lessThan', 'lessThanOrEqualTo', 'onlyInteger'
  @options 'allowBlank'

  validateEach: (errors, record, key, callback) ->
    options = @options
    value = record.get(key)
    return callback() if @handleBlank(value)
    if !value? || !(@isNumeric(value) || @canCoerceToNumeric(value))
      errors.add key, @format(key, 'not_numeric')
    else if options.onlyInteger and !@isInteger(value)
      errors.add key, @format(key, 'not_an_integer')
    else
      if options.greaterThan? and value <= options.greaterThan
        messageSymbol = 'greater_than'
        count = options.greaterThan
      if options.greaterThanOrEqualTo? and value < options.greaterThanOrEqualTo
        messageSymbol = 'greater_than_or_equal_to'
        count = options.greaterThanOrEqualTo
      if options.equalTo? and value != options.equalTo
        messageSymbol = 'equal_to'
        count = options.equalTo
      if options.lessThan? and value >= options.lessThan
        messageSymbol = 'less_than'
        count = options.lessThan
      if options.lessThanOrEqualTo? and value > options.lessThanOrEqualTo
        messageSymbol = 'less_than_or_equal_to'
        count = options.lessThanOrEqualTo
      if messageSymbol?
        errors.add key, messageSymbol, Batman.mixin({interpolations: {count}}, @options)
    callback()

  isNumeric: (value) ->
    !isNaN(parseFloat(value)) && isFinite(value)

  isInteger: (value) ->
    parseFloat(value) == (value | 0)

  canCoerceToNumeric: (value) ->
    `(value - 0) == value && value.length > 0`
Batman.Validators.push Batman.NumericValidator
