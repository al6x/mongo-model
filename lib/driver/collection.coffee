_       = require 'underscore'
helper  = require '../helper'
Driver  = require './driver'

# Integration with Model.
class Driver.Collection
  constructor: (@name, @options, @db) ->

  drop: (callback) ->
    @connect callback, (nCollection) ->
      nCollection.drop callback

  # CRUD.
  create: (obj, options..., callback) ->
    options = options[0] || {}

    # Adding default options.
    options = helper.merge safe: Driver.safe, options

    # Generate custom id if specified.
    if !helper.getId(obj) and Driver.generateId
      idGenerated = true
      helper.setId obj, Driver.generateId()

    # Support for Model.
    doc = if obj.isModel?() then obj.toHash() else obj

    # Saving.
    @connect callback, (nCollection) ->
      mongoOptions = helper.cleanOptions options
      doc = helper.convertDocIdToMongo doc
      nCollection.insert doc, mongoOptions, (err, result) ->
        result = result[0] unless err

        doc = helper.convertDocIdToDriver doc
        helper.setId obj, undefined if err and idGenerated
        helper.setId obj, helper.getId(doc) unless err

        callback err, result

  update: (args..., callback) ->
    [first, second, third] = args
    if first.isModel?()
      id = helper.getId(first) || throw new Error "can't update model without id!"
      [selector, obj, options] = [{id: id}, first, (second || {})]
    else
      [selector, obj, options] = [first, second, (third || {})]
    throw new Error "data object for update not provided!" unless obj

    # Support for Model.
    doc = if obj.isModel?() then obj.toHash() else obj

    # Adding default options. Because :multi works only with $ operators,
    # we need to check if it's applicable.
    options = if _(_(doc).keys()).any((k) -> /^\$/.test(k))
      helper.merge safe: Driver.safe, multi: Driver.multi, options
    else
      helper.merge safe: Driver.safe, options

    # Saving.
    @connect callback, (nCollection) ->
      mongoOptions = helper.cleanOptions options
      selector = helper.convertSelectorId selector
      doc = helper.convertDocIdToMongo doc
      nCollection.update selector, doc, mongoOptions, (args...) ->
        doc = helper.convertDocIdToDriver doc
        callback args...

  delete: (args..., callback) ->
    [first, second] = args
    if first.isModel?()
      id = helper.getId(first) || throw new Error "invalid arguments for update!"
      [selector, options] = [{id: id}, (second || {})]
    else
      [selector, options] = [first, (second || {})]

    # Adding default options.
    options = helper.merge safe: Driver.safe, options

    # Saving.
    @connect callback, (nCollection) ->
      mongoOptions = helper.cleanOptions options
      selector = helper.convertSelectorId selector
      nCollection.remove selector, mongoOptions, callback

  save: (obj, options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}
    if id = helper.getId(obj)
      @update {_id: id}, obj, options, callback
    else
      @create obj, options, callback

  # I prefer names `create` and `delete`, but
  # You still can use `insert` and `remove`.
  insert: (args...) -> @create args...
  remove: (args...) -> @delete args...

  # Querying.

  cursor: (args...) -> new Driver.Cursor @, args...

  find: (args...) -> @cursor args...

  # Indexes.

  ensureIndex: (args..., callback) ->
    @connect callback, (nCollection) ->
      args.push callback
      nCollection.ensureIndex args...

  dropIndex: (args..., callback) ->
    @connect callback, (nCollection) ->
      args.push callback
      nCollection.dropIndex args...

  # Allows to defer Collection creation.
  connect: (callback, next) ->
    unless @nCollection
      @db.nDb.collection @name, @options, (err, nCollection) =>
        return callback err if err
        @nCollection = nCollection
        next @nCollection
    else
      next @nCollection


# Making cursor's methods available directly on collection.
methods = [
  'first', 'all', 'next', 'close', 'count', 'each'

  'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable',
  'batchSize', 'fields', 'hint', 'explain', 'timeout'
]
for method in methods
  do (method) ->
    Driver.Collection.prototype[method] = (args...) ->
      @cursor()[method] args...