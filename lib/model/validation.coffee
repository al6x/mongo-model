_      = require 'underscore'
helper = require '../helper'
Model  = require './model'

exports.methods =
  errors: -> @_errors ||= new Model.Errors()

  valid: (args..., callback) ->
    throw new Error "callback required!" unless callback
    [options, embeddedModelsCache] = args
    options ||= {}
    embeddedModels = embeddedModelsCache || @_embeddedModels()

    that = @
    runBeforeCallbacks = (next) ->
      unless options.callbacks == false
        that.runCallbacks 'before', 'validate', (err, result) ->
          return callback err if err
          return callback null, false if result == false
          next()
      else
        next()

    runAfterCallback = (valid) ->
      unless options.callbacks == false
        that.runCallbacks 'after', 'validate', (err) ->
          return callback err if err
          callback null, valid
      else
        callback null, valid

    runBeforeCallbacks ->
      valid = true
      # Validating current model.
      that.runValidations (err) ->
        return callback err if err
        valid = _.isEmpty(that.errors())

        # Validating embedded models.
        counter = 0
        check = ->
          if counter < embeddedModels.length
            data = embeddedModels[counter]
            counter += 1
            fun = (err, result) ->
              return callback err if err
              unless result
                valid = false
                that.errors()[data.attr] ||= []
                that.errors()[data.attr].push "is invalid"
              check()
            data.model.valid options, data.embeddedModels, fun
          else
            runAfterCallback valid
        check()

  runValidations: (callback) ->
    throw new Error "callback required!" unless callback
    helper.clear @errors()

    validations = @constructor.validations()
    counter = 0
    that = @
    run = (err) ->
      return callback err if err
      if counter < validations.length
        validator = validations[counter]
        counter += 1
        validator.apply that, [run]
      else
        callback null
    run()

exports.classMethods =
  _validations: []
  validations: (clone = false) ->
    @_validations = _(@_validations).clone() if clone
    @_validations

  validate: (fun) ->
    @validations(true).push fun