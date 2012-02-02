helper = require '../lib/helper'
Model  = require '../lib/model'
require '../lib/sync'

require '../lib/spec'
global.p = (args...) -> console.log args...

# Patching should.
should = require 'should'
Object.defineProperty should.Assertion.prototype, 'exist',
  set: () ->
  get: () ->
    unless this.negate
      should.exist this.obj._wrapped
    else
      should.not.exist this.obj._wrapped
  configurable: true

# Namespace for temporarry objects.
global.Tmp = {}
beforeEach ->
  global.Tmp = {}

# Stubbing class loading.
Model.getClass = (name) ->
  Tmp[name] || (throw new Error "can't get '#{name}' class!")

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
    Fiber(->
      callback(done)
      done()
    ).run()

global._     = require('underscore')._
global.Model = Model