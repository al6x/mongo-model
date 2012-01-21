_       = require 'underscore'
helper  = require '../helper'

module.exports = class Model
  _model: true

  constructor: (attributes) ->
    @set attributes if attributes

  @_embedded: []
  @embedded: (args...) ->
    if args.length == 0
      @_embedded
    else
      @_embedded = @_embedded.concat args

  # Models are complex object - because it can contain nested models,
  # so in the end we get a complex object tree.
  # This method parses object tree and returns **a structure** representing it,
  # so we can save it in cache it and use many times.
  _embeddedModels: ->
    list = []
    that = @
    _(@constructor.embedded()).each (k) ->
      if obj = that[k]
        throw new Error "embedded model '#{k}' can't be a Function!" if _.isFunction obj
        if obj._model
          list.push model: obj, embeddedModels: obj._embeddedModels(), attr: k
        else if helper.isArray obj
          _(obj).each (v) ->
            list.push model: v, embeddedModels: v._embeddedModels(), attr: k if v._model
        else if helper.isObject obj
          _(obj).each (v) ->
            list.push model: v, embeddedModels: v._embeddedModels(), attr: k if v._model
    list