#= require ../object

class Batman.Query extends Batman.Object
  @OPTION_KEYS = ['limit', 'offset', 'order', 'where', 'distinct']

  constructor: (@base, options = {}) ->
    options.where ||= {}
    @set('options', new Batman.Object(options))

  where: (key, value) ->
    constraints = {}

    if Batman.typeOf(key) == 'String'
      constraints[key] = value
    else
      constraints = key

    @set('options.where', Batman.mixin({}, @get('options.where'), constraints))
    return this

  uniq: ->
    return @limit(1)

  limit: (amount) ->
    @set('options.limit', amount)
    return this

  offset: (amount) ->
    @set('options.offset', amount)
    return this

  order: (order) ->
    @set('options.order', order)
    return this

  distinct: ->
    @set('options.distinct', true)
    return this

  load: (callback) ->
    @base.search(this, callback)

  toJSON: -> @options.toJSON()

Batman.Queryable =
  initialize: ->
    for name in Batman.Query.OPTION_KEYS
      do (name) =>
        @[name] = ->
          query = new Batman.Query(this)
          query[name].apply(query, arguments)
          return query

Batman.QueryAccess =
  initialize: ->
    for name in Batman.Query.OPTION_KEYS
      do (name) =>
        @[name] = ->
          query = @get('query')
          query[name].apply(query, arguments)
          return this
