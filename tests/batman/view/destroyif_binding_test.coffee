helpers = window.viewHelpers

QUnit.module 'Batman.View destroy bindings'

asyncTest 'should permanently remove node from DOM and no child bindings should be created if keypath is true', ->
  accessorSpy = createSpy()
  class TestView extends Batman.View
    @accessor 'test', accessorSpy

  source = '<div><div class="foo" data-destroyif="foo"><span data-bind="test"></span></div></div>'
  context = foo: true, viewClass: TestView

  helpers.render source, false, context, (node) =>
    equal $('.foo', node).length, 0
    equal accessorSpy.callCount, 0
    QUnit.start()

asyncTest 'should remove attribute from node and continue rendering children if keypath is false', ->
  accessorSpy = createSpy()
  class TestView extends Batman.View
    @accessor 'test', accessorSpy

  source = '<div><div class="foo" data-destroyif="foo"><span data-bind="test"></span></div></div>'
  context = foo: false, viewClass: TestView

  helpers.render source, false, context, (node) =>
    equal $('.foo', node).length, 1
    equal $('.foo', node).attr('data-destroyif'), undefined
    equal accessorSpy.callCount, 1
    QUnit.start()

asyncTest 'should render nodes after the binding if keypath is false', ->
  source = '<div class="foo" data-destroyif="foo"></div><p class="test" data-bind="bar"></p>'
  context = foo: true, bar: 'bar'

  helpers.render source, false, context, (node) ->
    equal $('.foo', node).length, 0
    equal $('.test', node).html(), 'bar'
    QUnit.start()

asyncTest 'should not render or insert node if keypath transitions from true to false', ->
  accessorSpy = createSpy()
  class TestView extends Batman.View
    @accessor 'test', accessorSpy

  source = '<div><div class="foo" data-destroyif="foo"><span data-bind="test"></span></div></div>'
  context = foo: true, viewClass: TestView

  helpers.render source, false, context, (node, view) =>
    equal $('.foo', node).length, 0
    equal accessorSpy.callCount, 0

    view.set('foo', false)
    equal $('.foo', node).length, 0
    equal accessorSpy.callCount, 0

    QUnit.start()
