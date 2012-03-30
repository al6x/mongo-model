mongo = require './driver'

# Connecting to Mongo and cleaning database after each spec.

mongo._db = mongo.db
global.withMongo = (options = {}) ->

  # Connecting to Mongo.
  beforeEach (done) ->
    that = @
    mongo.db = (als, callback) -> callback null, that.db

    that.db = undefined
    mongo.server (err, server) ->
      return done err if err
      server.db 'test', (err, db) ->
        return done err if err
        db.clear (err) ->
          return done err if err
          that.db = db
          done()

  # Closing Mongo connection.
  afterEach ->
    if @db
      @db.close()
      @db = null
      mongo.db = mongo._db