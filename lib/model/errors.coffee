helper = require '../helper'
Model  = require './model'

module.exports = class Model.Errors

helper.definePropertyWithoutEnumeration Model.Errors.prototype, 'add', (attr, message) ->
  @[attr] ||= []
  @[attr].push message