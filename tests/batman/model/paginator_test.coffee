QUnit.module "Batman.Paginator",
  setup: ->
    error = {message: 'Test'}
    results = [new Batman.Model(id: 1), new Batman.Model(id: 2)]

    @paginator = new Batman.Paginator(Batman.Model)
    @paginator.get('query').load = (cb) -> cb?(error, results)

test "The paginator defaults to a limit of 1", ->
  equal @paginator.get('query.options.limit'), 1

asyncTest "paginate event emitted when models are loaded", 1, ->
  @paginator.on 'paginate', (models) ->
    equal models.length, 2
    QUnit.start()

  @paginator.load(@paginator.get('query'))

asyncTest "error event emitted when errors are returned", 1, ->
  @paginator.on 'error', (error) ->
    equal error.message, 'Test'
    QUnit.start()

  @paginator.load(@paginator.get('query'))

QUnit.module "Batman.OffsetPaginator",
  setup: ->
    results = [new Batman.Model(id: 1), new Batman.Model(id: 2)]
    @paginator = new Batman.OffsetPaginator(Batman.Model)
    @paginator.get('query').load = (cb) -> cb?(null, results)

test "First sets the offset to 0", ->
  @paginator.get('query').offset(10)
  @paginator.first()
  equal @paginator.get('query.options.offset'), 0

test "Prev cannot set the offset to a negative number", ->
  @paginator.prev()
  equal @paginator.get('query.options.offset'), 0

test "hasNext is true if the requested amount of models are returned", ->
  @paginator.get('query').limit(2)
  @paginator.first()
  ok @paginator.get('hasNext')

test "hasNext is false if less than the requested amount of models are returned", ->
  @paginator.get('query').limit(3)
  @paginator.first()
  ok !@paginator.get('hasNext')

test "hasPrev is true unless the offset is 0", ->
  ok !@paginator.get('hasPrev')
  @paginator.get('query').offset(1)
  ok @paginator.get('hasPrev')

QUnit.module "Batman.RelativePaginator",
  setup: ->
    results = [new Batman.Model(id: 1), new Batman.Model(id: 2)]
    @paginator = new Batman.RelativePaginator(Batman.Model)
    @paginator.get('query').load = (cb) -> cb?(null, results)

test "First sets the direction to next", ->
  @paginator.first()
  equal @paginator.get('query.options.where.direction'), 'next'

test "Next sets the relative ID to the last fetched ID", ->
  @paginator.first =>
    @paginator.next()
    equal @paginator.get('query.options.where.relative_id'), 2
    equal @paginator.get('query.options.where.direction'), 'next'

test "Prev sets the relative ID to the first fetched ID", ->
  @paginator.first =>
    @paginator.prev()
    equal @paginator.get('query.options.where.relative_id'), 1
    equal @paginator.get('query.options.where.direction'), 'prev'

test "hasNext is false if less than the requested amount of models are returned on a next call", ->
  @paginator.get('query').limit(2)
  @paginator.next()
  ok @paginator.get('hasNext')
  ok @paginator.get('hasPrev')

  @paginator.get('query').limit(3)
  @paginator.next()
  ok !@paginator.get('hasNext')
  ok @paginator.get('hasPrev')

test "hasPrev is false if less than the requested amount of models are returned on a prev call", ->
  @paginator.get('query').limit(2)
  @paginator.prev()
  ok @paginator.get('hasPrev')
  ok @paginator.get('hasNext')

  @paginator.get('query').limit(3)
  @paginator.prev()
  ok !@paginator.get('hasPrev')
  ok @paginator.get('hasNext')
