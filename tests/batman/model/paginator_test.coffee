QUnit.module "Batman.Paginator",
  setup: ->
    @paginator = new Batman.Paginator(Batman.Model)

test "The paginator defaults to a limit of 1", ->
  equal @paginator.get('query.options.limit'), 1

QUnit.module "Batman.OffsetPaginator",
  setup: ->
    @paginator = new Batman.OffsetPaginator(Batman.Model)
    @paginator.get('query').load = (cb) -> cb?()

test "First sets the offset to 0", ->
  @paginator.get('query').offset(10)
  @paginator.first()
  equal @paginator.get('query.options.offset'), 0

test "Prev cannot set the offset to a negative number", ->
  @paginator.prev()
  equal @paginator.get('query.options.offset'), 0

QUnit.module "Batman.RelativePaginator",
  setup: ->
    results = [new Batman.Model(id: 1), new Batman.Model(id: 2)]
    @paginator = new Batman.RelativePaginator(Batman.Model)
    @paginator.get('query').load = (cb) -> cb?([], results)

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
