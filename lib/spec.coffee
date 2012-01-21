mongo = require './driver'

mongo._db = mongo.db

# Connecting to Mongo and cleaning database after each spec.
global.withMongo = (options = {}) ->
  alias = options.alias  || '$db'

  # Stub.
  mongo.db = (als, callback) ->
    callback null, global[alias]

  # Connecting to Mongo.
  beforeEach ->
    global[alias] = null
    mongo.server (err, server) ->
      server.db 'test', (err, db) ->
        throw err if err
        db.clear (err) ->
          throw err if err
          global[alias] = db

    waitsFor( (-> !!global[alias]), "can't connect to Mongo server!", 1000)

  # Closing Mongo connection.
  afterEach ->
    if global[alias]
      global[alias].close()
      global[alias] = null