#= require ./query

class Batman.Paginator extends Batman.Object
  constructor: (model, options = {}) ->
    options.limit ||= 1
    @query = new Batman.Query(model, options)

  load: (query, callback) ->
    query.load (err, models) =>
      @fire('error', err) if err?
      @fire('paginate', models) if models?
      callback?(err, models)

class Batman.OffsetPaginator extends Batman.Paginator
  constructor: (model, options = {}) ->
    options.offset ||= 0
    super(model, options)

  first: (callback) ->
    @query.offset(0)
    @load(@query, callback)

  next: (callback) ->
    @query.offset(@query.get('options.offset') + @query.get('options.limit'))
    @load(@query, callback)

  prev: (callback) ->
    @query.offset(Math.max(@query.get('options.offset') - @query.get('options.limit'), 0))
    @load(@query, callback)

class Batman.RelativePaginator extends Batman.Paginator
  first: (callback) ->
    @query.where(direction: 'next')
    @load(@query, @_storeRelativeIDs(callback))

  next: (callback) ->
    @query.where(direction: 'next', relative_id: @lastID)
    @load(@query, @_storeRelativeIDs(callback))

  prev: (callback) ->
    @query.where(direction: 'prev', relative_id: @firstID)
    @load(@query, @_storeRelativeIDs(callback))

  _storeRelativeIDs: (callback) ->
    (error, models) =>
      if models?.length
        @firstID = models[0]?.get('id')
        @lastID  = models[models.length - 1]?.get('id')

      callback?(error, models)
