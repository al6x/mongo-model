module.exports = Driver = {}

_      = require 'underscore'
Server = require './server'

# ### Driver.
_(Driver).extend
  # Makes CRUD operation to throw error if there's something wrong (in native
  # mongo driver by default it's false).
  safe: true

  # Update all elements, not just first (in native mongo driver by default it's false).
  multi: true

  # Generates short and nice string ids (native mongo driver by default generates
  # BSON::ObjectId ids).
  # Set it as `null` if You want to disable it.
  idSize: 6
  idSymbols: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  generateId: ->
    [id, count] = ["", @idSize + 1]
    while count -= 1
      rand = Math.floor(Math.random() * @idSymbols.length)
      id += @idSymbols[rand]
    id

  # Use `id` instead of `_id` in objects, selectors, queries.
  # Set it as `false` if You want to disable it.
  convertId: true

  # Setting for pagination helper.
  perPage: 25
  maxPerPage: 100

  # Handy shortcut for configuring.
  configure: (options) -> _(@).extend options

  # Handy shortcut to create Server.
  server: (args...) -> new Driver.Server(args...)

  # Override to provide other behavior.
  fromHash: (doc) -> doc

  # Get database by alias, by using connection setting defined in options.
  # It cache database and returns the same for the next calls.
  #
  # Sample:
  #
  # Define Your setting.
  #
  #   Driver.configure({
  #     databases:
  #       blog:
  #         name: "blog_production"
  #       default:
  #         name: "default_production"
  #         host: "localhost"
  #   })
  #
  # And now You can use database alias to get the actual database.
  #
  #   db = mongo.db 'blog'
  #
  db: (alias = 'default') ->
    @databasesCache ?= {}
    unless db = @databasesCache[alias]
      options = @databases?[alias] || {}
      server = @server options.host, options.port, options.options
      name = options.name || 'default'
      db = server.db name
      @databasesCache[alias] = db
    db