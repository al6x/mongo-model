_       = require 'underscore'
NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Db
  constructor: (name, nServer, options = {}) ->
    @name = name
    @nDb = new NDriver.Db(name, nServer, options)

  collection: (name, options, callback) -> 
    collection = new Driver.Collection name, (options || {}), @
    callback?(null, collection)
    collection
      
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
          @nDb.collection name, options, (err, nCollection) =>
            return callback err if err
            nCollection.drop (err) ->
              return callback err if err
              drop()

      drop()