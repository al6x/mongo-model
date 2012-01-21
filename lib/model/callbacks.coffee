_      = require 'underscore'
helper = require '../helper'

exports.methods =
  runCallbacks: (type, event, callback) ->
    meta = @constructor.callbacks()[event] || (throw new Error "unknown event '#{event}'!}")
    funcs = meta[type]
    counter = 0
    that = @
    run = (err, result) ->
      return callback err if err
      if result == false
        if type == 'before'
          return callback null, false
        else
          return callback "can't interrupt 'after' callback!"

      if counter < funcs.length
        fun = funcs[counter]
        counter += 1
        fun.apply that, [run]
      else
        callback null, true
    run()

exports.classMethods =
  _callbacks: {
    validate : {before: [], after: []}
    create   : {before: [], after: []}
    update   : {before: [], after: []}
    save     : {before: [], after: []}
    delete   : {before: [], after: []},
  }
  callbacks: (clone = false) ->
    @_callbacks = helper.cloneCallbacks @_callbacks if clone
    @_callbacks

  before: (event, callback) ->
    meta = @callbacks(true)[event] || (throw new Error "unknown event '#{event}'!}")
    meta.before.push callback

  after: (event, callback) ->
    meta = @callbacks(true)[event] || (throw new Error "unknown event '#{event}'!}")
    meta.after.push callback