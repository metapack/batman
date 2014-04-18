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
    # allow normalize message to make key blank:
    [key, errorMessage] = @_normalizeMessage(key, error, options)
    super(new Batman.ValidationError(key, errorMessage))

  _normalizeMessage: (key, error, options) ->
    if message = options.message
      key = ""
      errorMessage = if typeof message is "function"
        message.apply(@record)
      else
        message
    else if @_isSymbol.exec(error)
      [key, errorMessage] = @_lookupMessage(key, error, options)
    else
      errorMessage = error
    [key, errorMessage]

  _lookupMessage: (key, error, options) ->
    interpolations = options.interpolations
    resourceName = @record.constructor.resourceName
    if resourceName and specificMessage = Batman.t("errors.messages.#{resourceName}.#{key}.#{error}", interpolations)
      key = ""
      errorMessage = specificMessage
    else
      errorMessage = Batman.t("errors.messages.#{error}", interpolations)
    [key, errorMessage]

  # Matches `too_long` and friends
  _isSymbol: /^[a-z_]+$/
