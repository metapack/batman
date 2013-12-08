#= require ./query

class Batman.Paginator extends Batman.Object
  @mixin Batman.QueryAccess

  constructor: (model, options = {}) ->
    options.limit ||= 1
    @query = new Batman.Query(model, options)

  load: (query, callback) ->
    query.load (err, models) =>
      @fire('error', err) if err?
      @fire('paginate', models) if models?.length
      callback?(err, models)

class Batman.OffsetPaginator extends Batman.Paginator
  @accessor 'hasPrev', -> @query.get('options.offset') > 0

  constructor: (model, options = {}) ->
    @set('hasNext', true)

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

  load: (query, callback) ->
    super(query, @_setAvailability(callback))

  _setAvailability: (callback) ->
    (error, models) =>
      @set('hasNext', models?.length == @query.get('options.limit'))
      callback?(error, models)

class Batman.RelativePaginator extends Batman.Paginator
  constructor: (model, options) ->
    @set('hasNext', true)
    @set('hasPrev', true)

    super(model, options)

  first: (callback) ->
    @query.where(direction: 'next')
    @load(@query, callback)

  next: (callback) ->
    @query.where(direction: 'next', relative_id: @lastID)
    @load(@query, callback)

  prev: (callback) ->
    @query.where(direction: 'prev', relative_id: @firstID)
    @load(@query, callback)

  load: (query, callback) ->
    super(query, @_storeRelativeIDs(callback))

  _storeRelativeIDs: (callback) ->
    (error, models) =>
      if models?.length
        @firstID = models[0]?.get('id')
        @lastID  = models[models.length - 1]?.get('id')

      @_setAvailability(models)
      callback?(error, models)

  _setAvailability: (models) ->
    if @query.get('options.where.direction') == 'next'
      @set('hasNext', models?.length == @query.get('options.limit'))
      @set('hasPrev', true)
    else
      @set('hasPrev', models?.length == @query.get('options.limit'))
      @set('hasNext', true)
