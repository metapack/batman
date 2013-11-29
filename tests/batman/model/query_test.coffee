QUnit.module "Batman.Query",
  setup: ->
    @query = new Batman.Query(Batman.Model)

test "All option methods return a query object for chaining", ->
  for option in Batman.Query.OPTION_KEYS
    ok @query[option]() instanceof Batman.Query

test "Query::get will query it's internal options", ->
  @query.limit(5)

  equal @query.get('limit'), 5
  ok !@query.get('load')

test "Chaining the same call will overwrite the first one", ->
  @query.limit(5).limit(10)
  equal @query.get('limit'), 10

test "Query::where mixes in constraints to the existing list", ->
  @query.where(foo: 'bar')
        .where(bar: 'foo')
        .where(a: 1, b: 2, foo: 'baz')

  equal @query.get('where.a'), 1
  equal @query.get('where.foo'), 'baz'

test "Mixing in Queryable defines methods which return new Queries", ->
  class Test extends Batman.Object
    @classMixin Batman.Queryable

  ok Test.limit(5) instanceof Batman.Query
