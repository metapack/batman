#= require ../../object

class Batman.SearchAdapter extends Batman.Object
  constructor: (@model) ->

  isSearchAdapter: true

  optionsFromQuery: (query) -> query.get('options').toObject()

  urlFromQuery: (query) ->
    @get('url') || Batman.developer.error('Search adapter requires a URL')

  request: (url, options, callback) ->
    new Batman.Request({
      data: options
      url: url
      success: (data) -> callback(null, data)
      error: (error) -> callback(error, null)
    })

  extractFromNamespace: (data, namespace) ->
    if namespace && data[namespace]?
      data[namespace]
    else
      data

  perform: (query, callback) ->
    url     = @urlFromQuery(query)
    options = @optionsFromQuery(query)

    @request url, options, (error, data) =>
      return callback(error) if error

      data      = @extractFromNamespace(data, @get('namespace'))
      instances = @model._makeOrFindRecordsFromData(data)

      callback(error, instances)
