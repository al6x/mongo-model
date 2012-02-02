_       = require 'underscore'
util    = require 'util'
helper  = require '../helper'

exports.methods =
  create: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback

    that = @
    embeddedModels = @_embeddedModels()

    runBeforeCallbacks = (next) ->
      that._runCallbacksRecursively 'before', 'save', options, embeddedModels, callback, ->
        that._runCallbacksRecursively 'before', 'create', options, embeddedModels, callback, next

    runAfterCallback = (next) ->
      that._runCallbacksRecursively 'after', 'create', options, embeddedModels, callback, ->
        that._runCallbacksRecursively 'after', 'save', options, embeddedModels, callback, ->
          callback null, true

    runBeforeCallbacks ->
      that._validate options, embeddedModels, callback, ->
        that.constructor.collection options, (err, collection) ->
          return callback err if err
          doc = that.toMongo()
          collection.create doc, options, (err, result) ->
            that._interceptSomeErrors err, callback, (err) ->
              return callback err, false if err

              # Marking object as saved.
              that._saved = true
              that._id = doc._id
              that._setOriginal doc

              runAfterCallback()

  _update: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    @_requireSaved()

    that = @
    embeddedModels = @_embeddedModels()

    runBeforeCallbacks = (next) ->
      that._runCallbacksRecursively 'before', 'save', options, embeddedModels, callback, ->
        that._runCallbacksRecursively 'before', 'update', options, embeddedModels, callback, next

    runAfterCallback = (next) ->
      that._runCallbacksRecursively 'after', 'update', options, embeddedModels, callback, ->
        that._runCallbacksRecursively 'after', 'save', options, embeddedModels, callback, ->
          callback null, true

    runBeforeCallbacks ->
      that._validate options, embeddedModels, callback, ->
        that.constructor.collection options, (err, collection) ->
          return callback err if err
          doc = that.toMongo()
          collection.update _id: that._id, doc, options, (err, result) ->
            that._interceptSomeErrors err, callback, (err) ->
              return callback err if err
              that._setOriginal doc
              runAfterCallback()

  delete: (options..., callback) ->
    options = options[0] || {}
    throw new Error "callback required!" unless callback
    @_requireSaved()

    that = @
    embeddedModels = @_embeddedModels()

    runBeforeCallbacks = (next) ->
      that._runCallbacksRecursively 'before', 'delete', options, embeddedModels, callback, next

    runAfterCallback = (next) ->
      that._runCallbacksRecursively 'after', 'delete', options, embeddedModels, callback, ->
        callback null, true

    runBeforeCallbacks ->
      that._validate options, embeddedModels, callback, ->
        that.constructor.collection options, (err, collection) ->
          return callback err if err
          collection.delete _id: that._id, options, (err, result) ->
            that._interceptSomeErrors err, callback, (err) ->
              return callback err if err
              that._setOriginal null
              runAfterCallback()

  save: (args...) ->
    # For some reason we can't count on `_id` to decide if object is saved,
    # instead we use special `_saved` attribute.
    if @_saved
      @_update args...
    else
      @create args...

  # Special methods.

  reload: (callback) ->
    throw new Error "callback required!" unless callback
    @_requireSaved()
    @constructor.first _id: @_id, (err, obj) =>
      unless err
        throw new Error "can't reload object (#{util.inspect(@)})!" unless obj
        helper.clear @
        _(@).extend obj
      callback err

  update: (doc, args...) ->
    @constructor.update {_id: @_id}, doc, args...

  _requireSaved: ->
    unless @_id
      throw new Error "can't update object without id (#{util.inspect(@)})!"
    unless @_saved
      throw new Error "can't update not saved object (#{util.inspect(@)})!"

  _validate: (options, embeddedModels, callback, next) ->
    unless options.validate == false
      fun = (err, result) ->
        return callback err if err
        return callback null, false unless result
        next()
      @valid options, embeddedModels, fun
    else
      next()

  _runCallbacksRecursively: (type, event, options, embeddedModels, callback, next) ->
    unless options.callbacks == false
      # Run callbacks for current model.
      @runCallbacks type, event, (err, result) ->
        return callback err if err
        return callback null, false if result == false

        # Run callbacks for embedded models.
        counter = 0
        run = ->
          if counter < embeddedModels.length
            data = embeddedModels[counter]
            counter += 1
            data.model._runCallbacksRecursively(
              type, event, options, data.embeddedModels, callback, run)
          else
            next()
        run()
    else
      next()

  # Some errors (unique index errors) are catched and stored inside of model errors.
  _interceptSomeErrors: (err, callback, next) ->
    if err and (err.code in [11000, 11001])
      @errors().base ||= []
      @errors().base.push 'not unique value'
      callback null, false
    else
      next err

exports.classMethods =
  build: (attributes) ->
    new @ attributes

  create: (attributes, args..., callback) ->
    throw new Error "callback required!" unless callback
    obj = @build attributes
    obj.save args..., (err, result) ->
      return callback err if err
      callback err, obj, result

  update: (selector, doc, options..., callback) ->
    throw new Error "callback required!" unless callback
    options = options[0] || {}
    @collection options, (err, collection) =>
      return callback err if err
      collection.update selector, doc, options, callback

  delete: (args..., callback) ->
    throw new Error "callback required!" unless callback
    [selector, options] = [args[0] || {}, args[1] || {}]
    @collection options, (err, collection) =>
      collection.delete true, selector, options, callback