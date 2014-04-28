#= require ../../object

class Batman.ValidationError extends Batman.Object
  @accessor 'fullMessage', ->
    [attribute, message] = @get('normalizedAttributeAndMessage')

    if attribute == 'base'
      Batman.t 'errors.base.format',
        message: message
    else
      Batman.t('errors.format',
        attribute: Batman.helpers.humanize(Batman.ValidationError.singularizeAssociated(attribute))
        message: message).trim()

  constructor: (record, attribute, message, options={}) ->
    super({record, attribute, message, options})

  @singularizeAssociated: (attribute) ->
    parts = attribute.split(".")
    for i in [0...parts.length - 1] by 1
      parts[i] = Batman.helpers.singularize(parts[i])
    parts.join(" ")

  @accessor 'normalizedAttributeAndMessage', ->
     @_normalizeMessage(@get('attribute'), @get('message'), @get('options'))

  _normalizeMessage: (attribute, error, options) ->
    if message = options.message
      attribute = ""
      errorMessage = if typeof message is "function"
        message.apply(@record)
      else
        message
    else if @_isSymbol.exec(error)
      [attribute, errorMessage] = @_lookupMessage(attribute, error, options)
    else
      errorMessage = error
    [attribute, errorMessage]

  _lookupMessage: (attribute, error, options) ->
    interpolations = options.interpolations
    resourceName = @record.constructor.resourceName
    if resourceName and specificMessage = Batman.t("errors.messages.#{resourceName}.#{attribute}.#{error}", interpolations)
      attribute = ""
      errorMessage = specificMessage
    else
      errorMessage = Batman.t("errors.messages.#{error}", interpolations)
    [attribute, errorMessage]

  # Matches `too_long` and friends
  _isSymbol: /^[a-z_]+$/
