_       = require 'underscore'
util    = require 'util'
helper  = require '../helper'
Driver  = require './driver'

Model = null
module.exports = class Driver.Cursor
  constructor: (collectionGetter, selector = {}, options = {}) ->
    [@collectionGetter, @selector, @options] = [collectionGetter, selector, options]

  find: (selector = {}, options = {}) ->
    selector = helper.merge @selector, selector
    options = helper.merge @options, options
    new @constructor @collectionGetter, selector, options

  # Get first document.
  #
  # Sample usage:
  #
  #   first (err, doc) ->
  #   first selector, (err, doc) ->
  #   first selector, options, (err, doc) ->
  #
  first: (args..., callback) ->
    throw new Error "callback required!" unless callback
    @all args..., (err, docs) ->
      unless err
        doc = docs[0] || null
      callback err, doc

  # Get all documents.
  #
  # Sample usage:
  #
  #   all (err, docs) ->
  #   all selector, (err, docs) ->
  #   all selector, options, (err, docs) ->
  #
  all: (args..., callback) ->
    throw new Error "callback required!" unless callback
    if args.length > 0
      @find(args...).all callback
    else
      list = []
      that = @
      fun = (err, doc) ->
        return callback err if err
        return callback err, list unless doc
        list.push doc
        that.next fun
      @next fun

  each: ->
    msg = "Don't use `each`, it's not implemented by intention!

      In async world there's no much sence of using `each`, because there's no way
      to make another async call inside of async each.

      Use `first`, `all` (with `limit` and pagination) or `next` for advanced scenario.

      If You still want one, it can be easilly done in about 5 lines of code, add it
      by Yourself if You really want it."
    throw new Error msg

  # Create cursor and use `next` to retrieve next document,
  # if there's no more documents it will return `null`.
  #
  # Sample usage:
  #
  #   getAllUnits: (race = 'Protoss', callback) ->
  #     cursor = myCollection.find race: race
  #     units = []
  #     fun = (err, doc) ->
  #       return callback err if err
  #       if doc
  #         units.push doc
  #         cursor.next fun
  #       else
  #         callback null, units
  #     cursor.next fun
  #
  next: (callback) ->
    throw new Error "callback required!" unless callback
    if @nCursor
      @_next callback
    else
      @collectionGetter @, (err, collection) =>
        return callback err if err
        options = helper.cleanOptions @options
        @nCursor ||= collection.nCollection.find @selector, options
        @_next callback

  _next: (callback) ->
    that = @
    @nCursor.nextObject (err, doc) ->
      return callback err if err
      if doc
        doc = that._processDoc doc unless that.options.object == false
        callback err, doc
      else
        that.nCursor = null
        callback err, null

  # Usually cursor closed automatically.
  # The only exception - if You use `next' and stop somewhere in the middle
  # of returned result set, without retrieving all the remaining results. In this case
  # You may want to close cursor explicitly (it will be anyway automatically closed by
  # timeout a little later, but You can use `close` to close it right now, without waiting for
  # timeout).
  close: (callback) ->
    unless @nCursor
      throw new Error "cursor #{util.inspect @selector} already closed!"
    @nCursor.close()
    @nCursor = null

  count: (args..., callback) ->
    throw new Error "callback required!" unless callback
    if args.length > 0
      @find(args...).count callback
    else
      @collectionGetter @, (err, collection) =>
        return callback err if err
        collection.nCollection.count @selector, callback

  # CRUD.

  delete: (args..., callback) ->
    throw new Error "callback required!" unless callback
    args2 = []
    if args[0] == true
      withCallbacks = true
      args.shift()
      args2.push true

    if args.length > 0
      args2.push callback
      @find(args...).delete args2...
    else
      @collectionGetter @, (err, collection) =>
        return callback err if err
        args2 = args2.concat [@selector, @options, callback]
        collection.delete args2...

  # Helpers.

  limit: (n) -> @find {}, limit: n
  skip: (n) -> @find {}, skip: n
  sort: (arg) -> @find {}, sort: arg
  paginate: (args...)->
    if args.length == 2
      [page, perPage] = args
    else
      options = args[0] || {}
      page = helper.safeParseInt options.page
      perPage = helper.safeParseInt options.perPage
    page ||= 1
    perPage ||= Driver.perPage
    perPage = Driver.maxPerPage if perPage > Driver.maxPerPage
    @skip((page - 1) * perPage).limit(perPage)

  snapshot: -> @find {}, snapshot: true
  fields: (arg) -> @find {}, fields: arg
  tailable: -> @find {}, tailable: true
  batchSize: (arg) -> @find {}, batchSize: arg
  fields: (arg) -> @find {}, fields: arg
  hint: (arg) -> @find {}, hint: arg
  explain: (arg) -> @find {}, explain: arg
  fields: (arg) -> @find {}, fields: arg
  timeout: (arg) -> @find {}, timeout: arg

  # Protected.

  _processDoc: (doc) ->
    if doc and doc._class
      Model ||= require '../model'
      doc = Model._fromMongo doc
    doc