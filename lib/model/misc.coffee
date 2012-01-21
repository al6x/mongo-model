_      = require 'underscore'
helper = require '../helper'
Model  = require './model'

exports.methods =
  eq: (other) -> _.isEqual @, other

  _cache: -> @_cache ||= {}

  # Use this as a way to get original unchanged model after You change model attributes.
  _setOriginal: (doc) ->
    @_originalDoc = doc
    @_originalObj = null
  _original: ->
    if @_originalDoc
      @_originalObj ||= Model._fromMongo @_originalDoc
    else
      null

  # Assignment.

  set: (attributes = {}) ->
    _(@).extend attributes
    @

  safeSet: (attributes = {}) ->
    _(attributes).each (v, k) =>
      setterName = "safeSet#{k[0..0].toUpperCase()}#{k[1..k.length]}"
      @[setterName] v if setterName of @
    @

exports.classMethods =
  # Assignment.
  accessible: (attr, type) ->
    setterName = "safeSet#{attr[0..0].toUpperCase()}#{attr[1..attr.length]}"
    @prototype[setterName] = (v) ->
      v = if type then helper.cast(v, type) else v
      @[attr] = v

  timestamps: ->
    @before 'create', (callback) ->
      @createdAt = new Date()
      @updatedAt = new Date()
      callback()

    @before 'save', (callback) ->
      @updatedAt = new Date()
      callback()