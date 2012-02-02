_       = require 'underscore'
util    = require 'util'
helper  = require '../helper'
Driver  = require '../driver'

# Persistence.
exports.methods =
  toMongo: ->
    hash = {}
    _(@).each (v, k) ->
      unless /^_/.test k
        hash[k] = v

    # Converting embedded objects.
    that = @
    _(@constructor.embedded()).each (k) ->
      if obj = that[k]
        if obj.toMongo
          r = obj.toMongo()
        else if helper.isArray obj
          r = []
          _(obj).each (v) ->
            v = if v.toMongo then v.toMongo() else v
            r.push v
        else if helper.isObject obj
          r = {}
          _(obj).each (v, k) ->
            v = if v.toMongo then v.toMongo() else v
            r[k] = v
        hash[k] = r

    # Adding _id and _class.
    hash._id    = @_id if @_id
    hash._class = @constructor.name || (
      throw new Error("no constructor name for #{util.inspect(@)}!"))

    # Callback.
    @afterToMongo hash if @afterToMongo

    hash

  toHash: -> @toMongo()

exports.classMethods =
  _db: 'default'

  db: (callback) ->
    name = @_db || (throw new Error "database for '#{@name}' model not specified!")
    Driver.db name, callback

  _collection: 'default'

  collection: (args...) ->
    if args.length == 1
      @_collection = args[0]
    else
      @_getCollection args...

  _getCollection: (options, callback) ->
    throw new Error "callback required!" unless callback
    collection = options.collection || @_collection || (
      throw new Error "collection for '#{@name}' model not specified!")

    if _.isString collection
      @db (err, db) =>
        return callback err if err
        unless db
          return callback(new Error("something wrong, got null instead of db!"))
        db.collection collection, callback
    else
      callback null, collection

  _fromMongo: (doc, parent) ->
    return doc unless doc._class
    klass = @getClass doc._class
    if klass.fromMongo
      klass.fromMongo doc, parent
    else
      obj = new klass()

      _(doc).each (v, k) -> obj[k] = v
      delete obj._class

      # Processing embedded objects.
      that = @
      _(klass.embedded()).each (k) ->
        if o = doc[k]
          if o._class
            r = that._fromMongo o, obj
          else if helper.isArray o
            r = []
            _(o).each (v) =>
              v = if v._class then that._fromMongo(v, obj) else v
              r.push v
          else if helper.isObject o
            r = {}
            _(o).each (v, k) =>
              v = if v._class then that._fromMongo(v, obj) else v
              r[k] = v
        obj[k] = r

      # Marking object as saved, only top-level object has `_saved` attribute.
      obj._saved = true unless parent

      # Saving original document.
      obj._setOriginal doc

      # If it's nested object also setting its parent.
      obj._parent = parent if parent

      # Callback.
      obj.afterFromMongo doc if obj.afterFromMongo

      obj

  # Override this method to provide different strategy of class loading.
  getClass: (name) ->
    global.Models?[name] || global[name] || (throw new Error "can't get '#{name}' class!")