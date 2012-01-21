Model  = require '../model'
helper = require '../helper'

require '../driver/sync'

objects = [
  [Model.prototype, ['create', 'update', 'delete', 'save', 'reload', 'exists', 'valid']]
  [Model, ['update', 'create', 'delete', 'exists']]
]

for [obj, methods] in objects
  helper.synchronizeMethods obj, methods