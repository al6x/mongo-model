NDriver = require 'mongodb'
Driver  = require './driver'

module.exports = class Driver.Server
  constructor: (host, port, options) ->
    host ||= '127.0.0.1'
    port ||= 27017
    options ||= {}
    @nServer = new NDriver.Server(host, port, options)

  db: (name, options..., callback) ->
    options = options[0] || {}
    db = new Driver.Db name, @nServer, options
    db.open (err, ndb) ->
      callback err, db