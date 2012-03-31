NDriver = require 'mongodb'
Driver  = require './driver'

class Driver.Server
  constructor: (host, port, options) ->
    host ?= '127.0.0.1'
    port ?= 27017
    options ?= {}
    @nServer = new NDriver.Server(host, port, options)

  db: (name, options = {}) -> new Driver.Db name, @, options