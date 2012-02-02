_       = require 'underscore'
helper  = require '../helper'
Driver  = require './driver'

module.exports = class Driver.Collection
  constructor: (nCollection) ->
    @nCollection = nCollection
    @name = nCollection.collectionName

  drop: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    @nCollection.drop (err, result) ->
      callback err, result

  # CRUD.
  create: (obj, options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    if obj and obj._model
      options = helper.merge collection: @, options
      obj.create options, callback
    else
      @_create obj, options, callback

  update: (args..., callback) ->
    throw new Error "callback required!" unless callback
    if args[0] and args[0]._model
      [obj, args...] = args
      options = args[0] || {}
      options = helper.merge collection: @, options
      obj.update options, callback
    else
      [selector, doc, args...] = args
      options = args[0] || {}
      @_update selector, doc, options, callback

  delete: (args..., callback) ->
    throw new Error "callback required!" unless callback
    if args[0] and args[0]._model
      # Delete model.
      [obj, args...] = args
      options = args[0] || {}
      options = helper.merge collection: @, options
      obj.delete options, callback
    else if args[0] == true
      # Delete by selector with callbacks in snapshot mode.
      args.shift()
      [selector, args...] = args
      options = args[0] || {}
      cursor = @cursor(selector, options).snapshot()
      [count, that] = [0, @]
      del = (err, doc) ->
        return callback err if err
        return callback err, count unless doc
        if doc._model
          that.delete doc, options, (err, result) ->
            return callback err if err
            return callback "can't delete #{doc._id} model" unless result
            count += 1
            cursor.next del
        else
          that.delete {_id: doc._id}, options, (err, result) ->
            return callback err if err
            count += 1
            cursor.next del
      cursor.next del
    else
      # Delete by selector.
      [selector, args...] = args
      options = args[0] || {}
      @_delete selector, options, callback

  save: (obj, options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}
    if obj and obj._model
      options = helper.merge collection: @, options
      obj.save options, callback
    else
      @_save obj, options, callback

  # I prefer names `create` and `delete`, but
  # You still can use `insert` and `remove`.
  insert: (args...) -> @create args...
  remove: (args...) -> @delete args...

  _create: (doc, options, callback) ->
    options = helper.merge safe: Driver.safe, options
    throw new Error "callback required!" unless callback

    # Generate custom id if specified.
    if !doc._id and Driver.generateId
      idGenerated = true
      doc._id = Driver.generateId()

    mongoOptions = helper.cleanOptions options
    @nCollection.insert doc, mongoOptions, (err, result) ->
      result = result[0] unless err
      delete doc._id if err and idGenerated

      callback err, result

  _update: (selector, doc, options, callback) ->
    options  = helper.merge safe: Driver.safe, options
    throw new Error "callback required!" unless callback

    # Because :multi works only with $ operators, we need to check if it's applicable.
    options = if _(_(doc).keys()).any((k) -> /^\$/.test(k))
      helper.merge safe: Driver.safe, multi: Driver.multi, options
    else
      helper.merge safe: Driver.safe, options

    mongoOptions = helper.cleanOptions options
    @nCollection.update selector, doc, mongoOptions, (err, result) ->
      callback err, result

  _delete: (selector, options, callback) ->
    options = helper.merge safe: Driver.safe, options
    throw new Error "callback required!" unless callback

    mongoOptions = helper.cleanOptions options
    @nCollection.remove selector, mongoOptions, (err, result) ->
      callback err, result

  _save: (doc, options, callback) ->
    throw new Error "callback required!" unless callback
    if _id = doc._id
      @update {_id: _id}, doc, options, callback
    else
      @create doc, options, callback

  # Querying.

  cursor: (args...) ->
    collectionGetter = (cursor, callback) =>
      throw new Error "callback required!" unless callback
      callback null, @
    new Driver.Cursor collectionGetter, args...

  find: (args...) -> @cursor args...

  # Indexes.

  ensureIndex: (args...) -> @nCollection.ensureIndex args...
  dropIndex: (args...) -> @nCollection.dropIndex args...

# Making cursor's methods available directly on collection.
_([
  'first', 'all', 'next', 'close', 'count', 'each'

  'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable',
  'batchSize', 'fields', 'hint', 'explain', 'timeout'
]).each (method) ->
  Driver.Collection.prototype[method] = (args...) ->
    @cursor()[method] args...