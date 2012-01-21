_       = require 'underscore'
helper  = require '../helper'
Model   = require './model'

exports.methods =
  exists: (options..., callback) ->
    options = options[0] || {}
    @constructor.exists _id: @_id, options, callback

exports.classMethods =
  cursor: (args...) ->
    collectionGetter = (cursor, callback) =>
      @collection cursor.options, callback
    new Model.Cursor @, collectionGetter, args...

  find: (args...) -> @cursor args...

  exists: (args..., callback) ->
    @count args..., (err, result) ->
      return callback err if err
      callback null, (result > 0)

# Making cursor's methods available directly on model.
_([
  'first', 'all', 'next', 'close', 'count', 'each'

  'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable',
  'batchSize', 'fields', 'hint', 'explain', 'timeout'
]).each (method) ->
  exports.classMethods[method] = (args...) ->
    @cursor()[method] args...