helper = require '../lib/helper'
Model  = require '../lib/model'
require '../lib/sync'

require 'mary'
require '../lib/spec'
require 'jasmine-ext'

# Namespace for temporarry objects.
beforeEach ->
  global.Tmp = {}

# Stubbing class loading.
Model.getClass = (name) ->
  Tmp[name] || (throw new Error "can't get '#{name}' class!")

global._     = require('underscore')._
global.Model = Model