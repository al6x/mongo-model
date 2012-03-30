_       = require 'underscore'
util    = require 'util'
{Model} = require '../model'

# Helpers.

Model._isArray = (obj) -> Array.isArray obj

Model._isObject = (obj) -> Object.prototype.toString.call(obj) == "[object Object]"

Model._cast = (v, type) ->
  type ?= String
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

_(Model.prototype).extend

  # Attribute Conversion.
  
  set: (attributes = {}, options = {}) ->
    if options.cast then @setWithCasting(attributes) else _(@).extend(attributes)
    @

  setWithCasting: (attributes = {}) ->
    for own k, v of attributes
      setterName = "set#{k[0..0].toUpperCase()}#{k[1..k.length]}WithCasting"
      @[setterName] v if setterName of @
    @
  
  # Model Conversion.
  
  toHash: ->
    hash = {}
    
    # Converting Attributes.
    for own k, v of @
      hash[k] = v unless /^_/.test k
    delete hash.errors
      
    # Converting children objects.
    that = @
    for k in @constructor._children
      if obj = that[k]
        if obj.toHash
          r = obj.toHash()
        if obj.toArray
          r = obj.toArray()
        else if Model._isArray obj
          r = []
          for v in obj
            v = if v.toHash then v.toHash() else v
            r.push v
        else if Model._isObject obj
          r = {}
          for own k, v of obj
            v = if v.toHash then v.toHash() else v
            r[k] = v
        hash[k] = r

    # Adding class.
    hash._class = @constructor.name ||
      throw new Error "no constructor name for #{util.inspect(@)}!"

    hash

_(Model).extend

  # Attribute Conversion.
  cast: (args...) ->
    if args.length == 1
      @cast attr, type for own attr, type of args[0]
    else
      [attr, type] = args
      setterName = "set#{attr[0..0].toUpperCase()}#{attr[1..attr.length]}WithCasting"
      @prototype[setterName] = (v) ->
        v = if type then Model._cast(v, type) else v
        @[attr] = v
        
  # Model Conversion.
  
  _children: []
  children: (args...) -> @_children = @_children.concat args
  
  fromHash: (hash, parent) -> @_fromHash hash, parent
  
  _fromHash: (hash, parent) ->
    return hash unless hash._class
    klass = @getClass hash._class
    if klass.fromHash and klass.fromHash != @fromHash
      klass.fromHash hash, parent
    else
      # Creating object.
      obj = new klass()
      
      # Restoring attributes.
      obj[k] = v for own k, v of hash
      delete obj._class

      # Processing children objects.
      that = @
      for k in klass._children
        if o = hash[k]
          if o._class
            r = that._fromHash o, obj
          else if Model._isArray o
            r = []
            for v in o
              v = if v._class then that._fromHash(v, obj) else v
              r.push v
          else if Model._isObject o
            r = {}
            for own k, v of o
              v = if v._class then that._fromHash(v, obj) else v
              r[k] = v
        obj[k] = r

      # # Marking object as saved, only top-level object has `_saved` attribute.
      # obj._saved = true unless parent

      # # Saving original hash.
      # obj._setOriginal hash

      # If it's nested object also setting its parent.
      obj._parent = parent if parent

      # Allow custom processing to be added.
      klass.afterFromHash? obj, hash

      obj

  # Override this method to provide different strategy of class loading.
  getClass: (name) ->
    global.Models?[name] || global[name] || throw new Error "can't get '#{name}' class!"