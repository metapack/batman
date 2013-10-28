class Batman.Query extends Batman.Object
  constructor: (options = {}) ->
    @options = new Batman.Hash(options)

  where: (options) ->
    @options.set('where', options)

  distinct: (value) ->
    @options.set('distinct', if typeof value == 'undefined' then true else !!value)

  uniq: (value) ->
    @distinct(value)

  order: (key) ->
    @options.set('order', key)

  group: (key) ->
    @options.set('group', key)

  limit: (amount) ->
    @options.set('limit', amount)

  offset: (amount) ->
    @options.set('offset', amount)

  extend: (query) ->
    newOptions = if query instanceof Batman.Query
      query.get('options')
    else
      new Batman.Hash(query)

    @set('options', @get('options').merge(newOptions))
    return this
