mongo = require '../lib/driver'
require '../lib/driver/sync'
require '../lib/driver/spec'

global.expect  = require 'expect.js'

global.p = (args...) -> console.log args...

# Support for synchronous specs.
global.itSync = (desc, callback) ->
  try
    require 'fibers'
  catch e
    console.log """
      WARN:
        You are trying to use synchronous mode.
        Synchronous mode is optional and requires additional `fibers` library.
        It seems that there's no such library in Your system.
        Please install it with `npm install fibers`."""
    throw e

  it desc, (done) ->
    that = @
    Fiber(->
      callback.apply that, [done]
      done()
    ).run()