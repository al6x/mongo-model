_     = require 'underscore'
Model = require './model/model'

module.exports = Model

# Mixing modules.
require './model/cursor'
require './model/errors'

_([
  'crud',
  'persistence',
  'query',
  'validation',
  'callbacks',
  'misc'
]).each (name) ->
  mod = require "./model/#{name}"
  _(Model.prototype).extend mod.methods
  _(Model).extend mod.classMethods if mod.classMethods