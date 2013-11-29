#= require ../object

class Batman.Query extends Batman.Object
  @OPTION_KEYS = ['limit', 'offset', 'order', 'where', 'distinct']

  constructor: (@base, options = {}) ->
    options.where ||= {}
    @set('options', new Batman.Object(options))

  get: (keypath) -> Batman.Object::get.call(@options, keypath)

  where: (constraints) ->
    @options.set('where', Batman.mixin(@get('where'), constraints))
    return this

  uniq: ->
    return @limit(1)

  limit: (amount) ->
    @options.set('limit', amount)
    return this

  offset: (amount) ->
    @options.set('offset', amount)
    return this

  order: (order) ->
    @options.set('order', order)
    return this

  distinct: ->
    @options.set('distinct', true)
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
