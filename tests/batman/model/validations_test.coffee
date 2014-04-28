validationsTestSuite = ->
  asyncTest "validation should leave the model in the same state it left it", ->
    class Product extends Batman.Model
      @validate 'name', presence: yes

    p = new Product
    oldState = p.get('lifecycle.state')
    p.validate (error, errors) ->
      equal p.get('lifecycle.state'), oldState
      QUnit.start()

  asyncTest "validate(callback) will call the callback only after all keys have been validated", ->
    class Product extends Batman.Model
      @validate 'name', 'price', presence: yes

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 2
      QUnit.start()

  asyncTest "length", 2, ->
    class Product extends Batman.Model
      @validate 'exact', length: 5
      @validate 'max', maxLength: 4
      @validate 'range', lengthWithin: [3, 5]

    p = new Product exact: '12345', max: '1234', range: '1234'
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0

      p.set 'exact', '123'
      p.set 'max', '12345'
      p.set 'range', '12'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 3
        QUnit.start()

  asyncTest "length with allow blank", 2, ->
    class Product extends Batman.Model
      @validate 'min', minLength: 4, allowBlank: true

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      p.set 'min', '123'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        QUnit.start()

  asyncTest "length with allow blank and empty string", ->
    class Product extends Batman.Model
      @validate 'min', minLength: 4, allowBlank: true

    p = new Product min: ''
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      p.set 'min', '123'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        equal errors.get('first.fullMessage'), "Min must be at least 4 characters"
        QUnit.start()

  asyncTest "presence", 3, ->
    class Product extends Batman.Model
      @validate 'name', presence: yes

    p = new Product name: 'nick'
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      p.unset 'name'
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        p.set 'name', ''
        p.validate (error, errors) ->
          throw error if error
          equal errors.length, 1
          QUnit.start()

  asyncTest "presence and length", 2, ->
    class Product extends Batman.Model
      @validate 'name', {presence: yes, maxLength: 10, minLength: 3}

    p = new Product
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 2

      p.set 'name', "beans"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "regexp", ->
    class Product extends Batman.Model
      @validate 'name', {pattern: /[0-9]+/}

    p = new Product(name: "foo")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.set 'name', "123"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "regexp with allow blank", ->
    class Product extends Batman.Model
      @validate 'name', {pattern: /[0-9]+/, allowBlank: true}

    p = new Product(name: "foo")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.unset 'name'
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest 'email', ->
    class User extends Batman.Model
      @validate 'email', {email: true}

    u = new User(email: 'not_a_email')
    u.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      u.set('email', 'test@test.fr')
      u.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        u.set('email', 'test@test')
        u.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "inclusion", ->
    class Product extends Batman.Model
      @validate 'name', inclusion: in: ["Batman", "Catwoman"]

    p = new Product(name: "Batman")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0

      p.set 'name', "The Penguin"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "inclusion with allow blank", ->
    class Product extends Batman.Model
      @validate 'name', allowBlank: true, inclusion: in: ["Batman", "Catwoman"]

    p = new Product(name: "Batman")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0

      p.unset 'name'
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "exclusion", ->
    class Product extends Batman.Model
      @validate 'name', exclusion: in: ["Batman", "Catwoman"]

    p = new Product(name: "Batman")
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1

      p.set 'name', "The Penguin"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "custom async validations which don't rely on model state", ->
    letItPass = true
    class Product extends Batman.Model
      @validate 'name', (errors, record, key, callback) ->
        setTimeout ->
          errors.add 'name', "didn't validate" unless letItPass
          callback()
        , 0

    p = new Product
    p.validate (error, errors) ->
      throw error if error
      equal errors.length, 0
      letItPass = false
      p.validate (error, errors) ->
        throw error if error
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric with string", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes

    p = new Product number: "5"
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric with allow blank", ->
    class Product extends Batman.Model
      @validate 'number', numeric: yes, allowBlank: yes

    p = new Product
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', "not_a_number"
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric using greaterThan", ->
    class Product extends Batman.Model
      @validate 'number', greaterThan: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 15
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "numeric using greaterThanOrEqualTo", ->
    class Product extends Batman.Model
      @validate 'number', greaterThanOrEqualTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "numeric using greaterThanOrEqualTo 0", ->
    class Product extends Batman.Model
      @validate 'number', greaterThanOrEqualTo: 0

    p = new Product number: -1
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 1
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "numeric using equalTo", ->
    class Product extends Batman.Model
      @validate 'number', equalTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 1
          QUnit.start()

  asyncTest "numeric using lessThan", ->
    class Product extends Batman.Model
      @validate 'number', lessThan: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', 15
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        QUnit.start()

  asyncTest "numeric using lessThanOrEqualTo", ->
    class Product extends Batman.Model
      @validate 'number', lessThanOrEqualTo: 10

    p = new Product number: 5
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', 10
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'number', 15
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 1
          QUnit.start()

  asyncTest "validation skipped with unless option as a function", ->
    class Product extends Batman.Model
      @validate 'state', presence: true, unless: (errors, record, key) -> record.get('country') == 'CA'

    p = new Product country: 'US'
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'country', 'CA'
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'country', 'US'
        p.set 'state', 'OH'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "validation skipped with if option as a function", ->
    class Product extends Batman.Model
      @validate 'state', presence: true, if: (errors, record, key) -> record.get('country') == 'US'

    p = new Product country: 'US'
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'country', 'CA'
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'country', 'US'
        p.set 'state', 'OH'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "validation skipped with if option as a string", ->
    class CompanyProfile extends Batman.Model
      @validate 'vat_number', presence: true, if: "country_in_eu"

    p = new CompanyProfile country_in_eu: true
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'country_in_eu', false
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'country_in_eu', true
        p.set 'vat_number', 'SE000000000000'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "validation skipped with unless option as a string", ->
    class CompanyProfile extends Batman.Model
      @validate 'vat_number', presence: true, unless: "country_outside_eu"

    p = new CompanyProfile country_outside_eu: false
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      p.set 'country_outside_eu', true
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 0
        p.set 'country_outside_eu', false
        p.set 'vat_number', 'SE0000000000000'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "numeric using onlyInteger", ->
    class Product extends Batman.Model
      @validate 'number', onlyInteger: true

    p = new Product number: 42
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'number', 4.2
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        p.set 'number', '15'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "confirmation", ->
    class Product extends Batman.Model
      @validate 'password', confirmation: true

    p = new Product password: 'test', password_confirmation: 'test'
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'password_confirmation', ''
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        equal errors.get('first.fullMessage'), "Password and confirmation do not match"
        p.set 'password_confirmation', 'test'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "confirmation allows you to supply which field it is confirming against", ->
    class Product extends Batman.Model
      @validate 'password', confirmation: "custom_confirmation"

    p = new Product password: 'test', custom_confirmation: 'test'
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 0
      p.set 'custom_confirmation', ''
      p.validate (err, errors) ->
        throw err if err
        equal errors.length, 1
        p.set 'custom_confirmation', 'test'
        p.validate (err, errors) ->
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "associated for hasMany", ->
    namespace = @
    class @Product extends Batman.Model
      @validate 'id', presence: true

    class @Collection extends Batman.Model
      @hasMany 'products', {namespace, autoload: false}
      @validate 'products', associated: true

    @collection = new @Collection
    @collection.get('products').add new @Product
    @collection.get('products').add new @Product
    @collection.validate (err, errors) =>
      throw err if err
      equal errors.length, 2
      @collection.get('products.toArray.0').set('id', 1)
      @collection.validate (err, errors) =>
        throw err if err
        equal errors.length, 1
        @collection.get('products.toArray.1').set('id', 2)
        @collection.validate (err, errors) =>
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "associated for belongsTo", ->
    namespace = @
    class @Product extends Batman.Model
      @belongsTo 'collection', {namespace, autoload: false}
      @validate 'collection', associated: true

    class @Collection extends Batman.Model
      @validate 'id', presence: true

    @product = new @Product
    @collection = new @Collection
    @product.validate (err, errors) =>
      throw err if err
      equal errors.length, 0
      @product.set 'collection', @collection
      @product.validate (err, errors) =>
        throw err if err
        equal errors.length, 1
        @collection.set('id', 2)
        @product.validate (err, errors) =>
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "associatedFields for hasMany", ->
    namespace = @
    class @Product extends Batman.Model
      @validate 'id', presence: true
      @validate 'name', presence: true

    class @Collection extends Batman.Model
      @hasMany 'products', {namespace, autoload: false}
      @validate 'products', associatedFields: true

    @collection = new @Collection
    @collection.get('products').add new @Product
    @collection.validate (err, errors) =>
      throw err if err
      equal errors.length, 2
      equal errors.get('name.first.message'), "can't be blank", "name error bubbles up"
      equal errors.get('id.first.message'), "can't be blank", "id error bubbles up"
      firstProduct = @collection.get('products.first')
      firstProduct.set('id', 1)
      firstProduct.set('name', "Snuggie")
      @collection.validate (err, errors) =>
        throw err if err
        equal errors.length, 0
        QUnit.start()

  asyncTest "associatedFields for belongsTo", ->
    namespace = @
    class @Product extends Batman.Model
      @belongsTo 'collection', {namespace, autoload: false}
      @validate 'collection', associatedFields: true

    class @Collection extends Batman.Model
      @validate 'id', presence: true
      @validate 'name', presence: true

    @product = new @Product
    @collection = new @Collection
    @product.validate (err, errors) =>
      throw err if err
      equal errors.length, 0
      @product.set 'collection', @collection
      @product.validate (err, errors) =>
        throw err if err
        equal errors.length, 2
        equal errors.get('id.first.message'), "can't be blank"
        equal errors.get('name.first.message'), "can't be blank"
        @collection.set('id', 2)
        @collection.set('name', 'As Seen on TV')
        @product.validate (err, errors) =>
          throw err if err
          equal errors.length, 0
          QUnit.start()

  asyncTest "Validation takes a custom message", ->
    class Product extends Batman.Model
      @validate 'name', presence: true, message: "You can't have a product without a name"

    p = new Product(name: null)
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      equal errors.get('first.fullMessage'), "You can't have a product without a name"
      QUnit.start()

  asyncTest "Validation takes a custom message which can be a function", ->
    class Product extends Batman.Model
      @validate 'name', presence: true, message: -> "You have to put a name for product ##{@get('id')}"
    p = new Product(name: null, id: 50)
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 1
      equal errors.get('first.fullMessage'), "You have to put a name for product #50"
      QUnit.start()

  asyncTest "Validation takes a custom translation as errors.messages.resourceName.field.errorKey and doesnt interfere with other messages", ->
    errorMessageObject = {product: {name: {blank: "This must have a name!"}}}
    try
      # this doesn't work after i18n is enabled:
      Batman.mixin(Batman.translate.messages.errors.messages, errorMessageObject)
    catch
      Batman.I18N.set('locales.en.errors.messages.product', errorMessageObject.product)

    class Product extends Batman.Model
      @resourceName: 'product'
      @validate 'name', presence: true
      @validate 'brand', presence: true

    p = new Product(name: null, brand: null)
    p.validate (err, errors) ->
      throw err if err
      equal errors.length, 2
      equal errors.get('first.fullMessage'), "This must have a name!"
      equal errors.get('last.fullMessage'), "Brand can't be blank"
      QUnit.start()

QUnit.module "Batman.Model: Validations"
validationsTestSuite()

QUnit.module "Batman.Model: Validations with I18N",
  setup: ->
    Batman.I18N.enable()
  teardown: ->
    Batman.I18N.disable()

validationsTestSuite()

QUnit.module "Batman.Model: binding to errors",
  setup: ->
    class @Product extends Batman.Model
      @validate 'name', {presence: true}

    @product = new @Product
    @someObject = Batman {product: @product}

asyncTest "errors set length should be observable", 4, ->
  count = 0
  errorsAtCount =
    0: 1
    1: 0

  @product.get('errors').observe 'length', (newLength, oldLength) ->
    equal newLength, errorsAtCount[count++]

  @product.validate (err, errors) =>
    throw err if err
    equal errors.get('length'), 1
    @product.set 'name', 'Foo'
    @product.validate (err, errors) =>
      throw err if err
      equal errors.get('length'), 0
      QUnit.start()

asyncTest "errors set contents should be observable", 3, ->
  x = @product.get('errors.name')
  x.observe 'length', (newLength, oldLength) ->
    equal newLength, 1

  @product.validate (error, errors) =>
    throw error if error
    equal errors.get('length'), 1
    equal errors.length, 1
    QUnit.start()

asyncTest "errors set length should be bindable", 4, ->
  @someObject.accessor 'productErrorsLength', ->
    errors = @get('product.errors')
    errors.get('length')

  equal @someObject.get('productErrorsLength'), 0, 'the errors should start empty'

  @someObject.observe 'productErrorsLength', (newVal, oldVal) ->
    return if newVal == oldVal # Prevents the assertion below when the errors set is cleared and its length goes from 0 to 0
    equal newVal, 1, 'the foreign observer should fire when errors are added'

  @product.validate (error, errors) =>
    throw error if error
    equal errors.length, 1, 'the validation shouldn\'t succeed'
    equal @someObject.get('productErrorsLength'), 1, 'the foreign key should have updated'
    QUnit.start()

asyncTest "errors set contents should be bindable", 4, ->
  @someObject.accessor 'productNameErrorsLength', ->
    errors = @get('product.errors.name.length')

  equal @someObject.get('productNameErrorsLength'), 0, 'the errors should start empty'

  @someObject.observe 'productNameErrorsLength', (newVal, oldVal) ->
    return if newVal == oldVal # Prevents the assertion below when the errors set is cleared and its length goes from 0 to 0
    equal newVal, 1, 'the foreign observer should fire when errors are added'

  @product.validate (error, errors) =>
    throw error if error
    equal errors.length, 1, 'the validation shouldn\'t succeed'
    equal @someObject.get('productNameErrorsLength'), 1, 'the foreign key should have updated'
    QUnit.start()

QUnit.module "Batman.ValidationError",
  setup: ->
    class Product extends Batman.Model
    @record = new Product

test "ValidationError should get full message", ->
  error = new Batman.ValidationError(@record, "foo", "isn't valid")
  equal error.get('fullMessage'), "Foo isn't valid"

test "ValidationError should humanize attribute in the full message", ->
  error = new Batman.ValidationError(@record, "fooBarBaz", "isn't valid")
  equal error.get('fullMessage'), "Foo bar baz isn't valid"

test "ValidationError doesn't add 'base' to fullMessage", ->
  error = new Batman.ValidationError(@record, 'base', "Model isn't valid")
  equal error.get('fullMessage'), "Model isn't valid"

test "ValidationError should singularize associated attribute in the full message", ->
  error = new Batman.ValidationError(@record, "emails.address", "isn't valid")
  equal error.get('fullMessage'), "Email address isn't valid"
  error = new Batman.ValidationError(@record, "users.emails.address", "isn't valid")
  equal error.get('fullMessage'), "User email address isn't valid"
