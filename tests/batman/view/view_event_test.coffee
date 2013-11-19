
QUnit.module 'Batman.View lifecycle events',
  setup: ->
    @superview = new Batman.View(html: '')
    @superview.addToParentNode(document.body)
    @view = new Batman.View(html: '')

    @attachViewSpies = (view) ->
      events = [
        'ready'
        'destroy'
        'viewDidMoveToSuperview'
        'viewWillAppear'
        'viewDidAppear'
        'viewWillRemoveFromSuperview'
        'viewWillDisappear'
        'viewDidDisappear'
        'viewDidLoad'
      ]
      ret = {}
      for key in events
        @view.on key, ret[key] = createSpy()
      ret

  teardown: ->
    @superview.die() unless @superview.isDead

test 'adding to and removing from a superview fires the correct events', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 1
  equal spies.viewDidMoveToSuperview.callCount, 1
  equal spies.viewWillAppear.callCount, 1
  equal spies.viewDidAppear.callCount, 1

  @view.removeFromSuperview()
  equal spies.viewWillRemoveFromSuperview.callCount, 1
  equal spies.viewWillDisappear.callCount, 1
  equal spies.viewDidDisappear.callCount, 1
  equal spies.destroy.callCount, 0

test 'manipulating nested views fires the correct events', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 1
  equal spies.viewDidMoveToSuperview.callCount, 1
  equal spies.viewWillAppear.callCount, 1
  equal spies.viewDidAppear.callCount, 1

  @superview.removeFromParentNode()
  equal spies.viewWillRemoveFromSuperview.callCount, 0
  equal spies.viewWillDisappear.callCount, 1
  equal spies.viewDidDisappear.callCount, 1
  equal spies.destroy.callCount, 0

test 'killing the superview fires the correct events on subviews', ->
  spies = @attachViewSpies(@view)

  @superview.subviews.add(@view)
  equal spies.ready.callCount, 1
  equal spies.viewDidMoveToSuperview.callCount, 1
  equal spies.viewWillAppear.callCount, 1
  equal spies.viewDidAppear.callCount, 1

  @superview.die()
  equal spies.viewWillRemoveFromSuperview.callCount, 1
  equal spies.viewWillDisappear.callCount, 1
  equal spies.viewDidDisappear.callCount, 1
  equal spies.destroy.callCount, 1

test 'appear events are only called if the view is really in the DOM', ->
  spies = @attachViewSpies(@view)
  viewWillAppear = createSpy()
  viewDidAppear = createSpy()

  class @superview.TestView extends Batman.View
    viewWillAppear: viewWillAppear
    viewDidAppear: viewDidAppear

  @view.set('html', '<div data-insertif="insertKey"><div data-view="TestView"></div></div>')
  @superview.subviews.add(@view)

  equal viewWillAppear.callCount, 0
  equal viewDidAppear.callCount, 0

  @view.set('insertKey', true)

  equal viewWillAppear.callCount, 1
  equal viewDidAppear.callCount, 1

