Driver = require '../driver'
util   = require 'util'
_      = require 'underscore'

synchronize = (fn) ->
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

synchronizeMethods = (obj, methods) ->
  for name in methods
    method = obj[name] || (throw new Error "no method #{name} in #{util.inspect(obj)}!")
    obj[name] = synchronize method

objects = [
  [Driver.Db.prototype, ['collectionNames', 'clear']]
  [Driver.Collection.prototype, ['drop', 'create', 'update', 'delete', 'save',
    'ensureIndex', 'dropIndex']]
  [Driver.Cursor.prototype, ['first', 'all', 'next', 'count', 'delete']]
]

for [obj, methods] in objects
  synchronizeMethods obj, methods