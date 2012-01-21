_ = require 'underscore'

# ### Driver.
module.exports = Driver =
  # Makes CRUD operation to throw error if there's something wrong (in native
  # mongo driver by default it's false).
  safe: true

  # Update all elements, not just first (in native mongo driver by default it's false).
  multi: true

  # Generates short and nice string ids (native mongo driver by default generates
  # BSON::ObjectId ids).
  # Set it as `null` if You want to disable it.
  idSize: 6
  idSymbols: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split('')
  generateId: ->
    [id, count] = ["", @idSize + 1]
    while count -= 1
      rand = Math.floor(Math.random() * @idSymbols.length)
      id += @idSymbols[rand]
    id

  # Setting for pagination helper.
  perPage: 25
  maxPerPage: 100

  # Handy shortcut for configuring.
  configure: (options) -> _(@).extend options

  # Handy shortcut, also support usage with callback.
  # It's not actually async, but for consistency with other API it also
  # support callback-style usage.
  server: (args...) ->
    callback = args.pop() if _.isFunction _(args).last()
    server = new Driver.Server(args...)
    callback null, server if callback
    server

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
  #   mongo.db 'blog', (err, db) -> ...
  #
  db: (dbAlias..., callback) ->
    dbAlias = dbAlias[0] || 'default'

    @dbCache ||= {}
    if db = @dbCache[dbAlias]
      callback null, db
    else
      dbOptions = @databases?[dbAlias] || {}
      # throw new Error "no setting for '#{dbAlias}' db alias!" unless dbOptions
      server = @server dbOptions.host, dbOptions.port, dbOptions.options

      dbName = dbOptions.name || 'default'
      # throw new Error "no database name for '#{dbAlias}' db alias!" unless dbName
      server.db dbName, (err, db) =>
        return callback err if err
        @dbCache[dbAlias] = db
        callback null, db