_       = require 'underscore'
helper  = require '../helper'
Driver  = require '../driver'
Model   = require './model'

module.exports = class Model.Cursor extends Driver.Cursor
  constructor: (model, collectionGetter, selector = {}, options = {}) ->
    [@model, @collectionGetter, @selector, @options] =
      [model, collectionGetter, selector, options]

  find: (selector = {}, options = {}) ->
    selector = helper.merge @selector, selector
    options = helper.merge @options, options
    new @constructor @model, @collectionGetter, selector, options

  build: (attributes = {}) ->
    attributes = helper.merge @selector, attributes
    @model.build attributes

  create: (attributes = {}) ->
    attributes = helper.merge @selector, attributes
    @model.create attributes