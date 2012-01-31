mongo = require './driver'

mongo._db = mongo.db

global.$db = null

# Connecting to Mongo and cleaning database after each spec.
global.withMongo = (options = {}) ->
  # Stub.
  mongo.db = (als, callback) ->
    callback null, global.$db

  # Connecting to Mongo.
  beforeEach (done) ->
    global.$db = null
    mongo.server (err, server) ->
      return done err if err
      server.db 'test', (err, db) ->
        return done err if err
        db.clear (err) ->
          return done err if err
          global.$db = db
          done()

  # Closing Mongo connection.
  afterEach ->
    if global.$db
      global.$db.close()
      global.$db = null