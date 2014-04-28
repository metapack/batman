#= require ../../set/set

# `ErrorSet` is a simple subclass of `Set` which makes it a bit easier to
# manage the errors on a model.
class Batman.ErrorsSet extends Batman.Set
  # ErrorsSet knows its record so it can look up translations
  constructor: (@record) ->
    super()
  # Define a default accessor to get the set of errors on a key
  @accessor (key) -> @indexedBy('attribute').get(key)

  # Define a shorthand method for adding errors to a key.
  add: (key, error, options={}) ->
    super(new Batman.ValidationError(@record, key, error, options))

