#= require ../../set/set

# `ErrorSet` is a simple subclass of `Set` which makes it a bit easier to
# manage the errors on a model.
class Batman.ErrorsSet extends Batman.Set
  # ErrorsSet knows its record so it can look up translations
  constructor: (@record) ->
    super()
  # Define a default accessor to get the set of errors on a key
  @accessor (key) -> @indexedBy('attribute').get(key)

  # Define a shorthand method for adding errors to a key.
  add: (key, error, options={}) ->
    if message = options.message
      key = ""
      errorMessage = if typeof message is "function"
        message.apply(@record)
      else
        message
    else if @_isSymbol.exec(error)
      interpolations = options.interpolations
      if @record.constructor.resourceName and specificMessage = Batman.t("errors.messages.#{@record.constructor.resourceName}.#{key}.#{error}", interpolations)
        key = ""
        errorMessage = specificMessage
      else
        errorMessage = Batman.t("errors.messages.#{error}", interpolations)
    else
      errorMessage = error
    super(new Batman.ValidationError(key, errorMessage))

  # Matches `too_long` and friends
  _isSymbol: /^[a-z_]+$/
