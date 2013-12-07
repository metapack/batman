QUnit.module "Batman.Query",
  setup: ->
    @query = new Batman.Query(Batman.Model)

test "All option methods return a query object for chaining", ->
  for option in Batman.Query.OPTION_KEYS
    ok @query[option]() instanceof Batman.Query

test "Chaining the same call will overwrite the first one", ->
  @query.limit(5).limit(10)
  equal @query.get('options.limit'), 10

test "Query::where can be called with an object or key and value", ->
  @query.where(foo: 'bar')
  equal @query.get('options.where.foo'), 'bar'

  @query.where('foo', 'baz')
  equal @query.get('options.where.foo'), 'baz'

test "Query::where mixes in constraints to the existing list", ->
  @query.where(foo: 'bar')
        .where(bar: 'foo')
        .where(a: 1, b: 2, foo: 'baz')

  equal @query.get('options.where.a'), 1
  equal @query.get('options.where.foo'), 'baz'

test "Mixing in Queryable defines methods which return new Queries", ->
  class Test extends Batman.Object
    @classMixin Batman.Queryable

  ok Test.limit(5) instanceof Batman.Query
