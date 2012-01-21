_    = require 'underscore'
util = require 'util'

module.exports =
  isArray  : (obj) -> Array.isArray obj
  isObject : (obj) -> Object.prototype.toString.call(obj) == "[object Object]"

  merge: (to, from) ->
    _(_(to).clone()).extend from

  safeParseInt: (v) ->
    v = v.toString() if _.isNumber v
    return null unless _.isString v
    return null if v.length > 20
    return null unless v.length > 0
    parseInt v

  cleanOptions: (options) ->
    list = ['db', 'collection', 'object', 'validate', 'callbacks', 'cache']
    options = _(options).clone()
    delete options[option] for option in list
    options

  clear: (obj) -> _(obj).each (v, k) -> delete obj[k]

  # _tempConstructor = ->
  # _new: (constructor, args...) ->
  #   _tempConstructor.prototype = constructor.prototype
  #   instance = new _tempConstructor()
  #   constructor.apply instance, args
  #   instance

  cast: (v, type) ->
    type ||= String
    casted = if type == String
      v.toString()
    else if type == Number
      if _.isNumber(v)
        v
      else if _.isString v
        tmp = parseInt v
        tmp if _.isNumber tmp
    else if type == Boolean
      if _.isBoolean v
        v
      else if _.isString v
        v == 'true'
    else if type == Date
      if _.isDate v
        v
      else if _.isString v
        tmp = new Date v
        tmp if _.isDate tmp
    else
      throw new Error "can't cast, unknown type (#{util.inspect type})!"

    throw new Error "can't cast, invalid value (#{util.inspect v})!" unless casted?
    casted

  cloneCallbacks: (callbacks) ->
    clone = {}
    _(callbacks).each (v, k) ->
      clone[k] = {}
      _(v).each (v2, k2) ->
        clone[k][k2] = _(v2).clone()
    clone

  synchronize: (fn) ->
    try
      Future = require 'fibers/future'
    catch e
      console.log """
        WARN:
          You are trying to use mongo-model in synchronous mode.
          Synchronous mode is optional and requires additional `fibers` library.
          It seems that there's no such library in Your system.
          Please install it with `npm install fibers`."""
      throw e

    (args...) ->
      # There's a convention, in async methdos **callback always should be
      # the last argument, and it's always required**.
      #
      # So, using this convention we can decide - should we supply syncronized
      # callback or not. If there's no callback - it means a synchronized
      # call, and we supply Future as a synchronized callback.
      # If there's already a callback - we do nothing.
      last = _(args).last()
      if Fiber.current and (!last or !_.isFunction(last))
        future = new Future()
        args.push future.resolver()
        fn.apply @, args
        future.wait()
      else
        fn.apply @, args

  synchronizeMethods: (obj, methods) ->
    for name in methods
      method = obj[name] || (throw new Error "no method #{name} in #{util.inspect(obj)}!")
      obj[name] = @synchronize method

  definePropertyWithoutEnumeration: (obj, name, value) ->
    Object.defineProperty obj, name,
        enumerable: false
        writable: true
        configurable: true
        value: value