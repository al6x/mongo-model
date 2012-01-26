helper = require '../helper'
Model  = require './model'

module.exports = class Model.Errors

helper.definePropertyWithoutEnumeration Model.Errors.prototype, 'add', (args...) ->
  if args.length == 1
    @add attr, message for attr, message of args[0]
  else
    [attr, message] = args
    @[attr] ||= []
    @[attr].push message