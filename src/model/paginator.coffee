#= require ./query

class Batman.Paginator extends Batman.Object
  constructor: (model, options = {}) ->
    options.limit ||= 1
    @query = new Batman.Query(model, options)

class Batman.OffsetPaginator extends Batman.Paginator
  constructor: (model, options = {}) ->
    options.offset ||= 0
    super(model, options)

  first: (callback) ->
    @query.offset(0).load(callback)

  next: (callback) ->
    @query.offset(@query.get('offset') + @query.get('limit'))
          .load(callback)

  prev: (callback) ->
    @query.offset(Math.max(@query.get('offset') - @query.get('limit'), 0))
          .load(callback)

class Batman.RelativePaginator extends Batman.Paginator
  first: (callback) ->
    @query.where(direction: 'next')
          .load(@_storeRelativeIDs(callback))

  next: (callback) ->
    @query.where(direction: 'next', first_id: @firstID)
          .load(@_storeRelativeIDs(callback))

  prev: (callback) ->
    @query.where(direction: 'prev', last_id: @lastID)
          .load(@_storeRelativeIDs(callback))

  _storeRelativeIDs: (callback) ->
    (error, models) =>
      if models?.length
        @firstID = models[0]?.get('id')
        @lastID  = models[models.length - 1]?.get('id')

      callback?(error, models)
