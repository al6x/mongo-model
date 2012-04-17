_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

module.exports = class Driver.Db
  constructor: (name, nServer, options = {}) ->
    @name = name
    @nDb = new NDriver.Db(name, nServer, options)

  collection: (name, options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    @nDb.collection name, options, (err, nCollection) =>
      collection = new Driver.Collection(nCollection) unless err
      callback err, collection

  open: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    @nDb.open (err, nDb) =>
      callback err, @

  close: ->
    @nDb.close()

  collectionNames: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    dbName = @name
    @nDb.collectionNames (err, names) ->
      names = _(names).map (obj) -> obj.name.replace("#{dbName}.", '') unless err
      callback err, names

  clear: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback

    @collectionNames options, (err, names) =>
      return callback err if err
      names = _(names).select((name) -> !/^system\./.test(name))
      counter = 0
      drop = =>
        if counter == names.length
          callback null
        else
          name = names[counter]
          counter += 1
          @collection name, options, (err, collection) ->
            return callback err if err
            collection.drop (err) ->
              drop err

      drop()
  authenticate: (username, password, callback) ->
    throw new Error "callback required!" unless callback
    @nDb.authenticate username, password, (err, success) =>
      return callback err if err
      return callback new Error("Could not authenticate user #{username}") unless success
      callback null, @