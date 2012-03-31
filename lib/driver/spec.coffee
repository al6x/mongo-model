mongo = require './driver'

# Connecting to Mongo and cleaning database before each spec.

mongo._db = mongo.db
global.withMongo = (options = {}) ->

  # Connecting to clean test database.
  beforeEach (done) ->
    mongo.db = (als) => @db
    @db = mongo.server().db 'test'
    @db.clear done

  # Closing test database.
  afterEach ->
    mongo.db = mongo._db
    if @db
      @db.close()
      @db = undefined