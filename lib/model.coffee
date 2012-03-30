_       = require 'underscore'

# Model.
exports.Model = class Model
  constructor: (attributes) ->
    @set @defaults if @defaults
    @set attributes if attributes
    @errors = new Errors()

  eq: (other) -> _.isEqual @, other

  set: (attributes = {}, options = {}) ->
    @[k] = v for own k, v of attributes
    @
    
  clear: -> delete @[k] for own k, v of @      
    
  valid: -> @errors.size() == 0
  
  invalid: -> !@valid()
    
# Errors.

definePropertyWithoutEnumeration = (obj, name, value) ->
  Object.defineProperty obj, name,
      enumerable: false
      writable: true
      configurable: true
      value: value

exports.Errors = class Errors

definePropertyWithoutEnumeration Errors.prototype, 'clear', -> 
  delete @[k] for own k, v of @
  
definePropertyWithoutEnumeration Errors.prototype, 'add', (args...) ->
  if args.length == 1
    @add attr, message for attr, message of args[0]
  else
    [attr, message] = args
    @[attr] ?= []
    @[attr].push message