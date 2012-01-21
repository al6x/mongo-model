Driver  = require '../driver'
helper = require '../helper'

objects = [
  [Driver, ['db']]
  [Driver.Server.prototype, ['db']]
  [Driver.Db.prototype, ['collection', 'open', 'collectionNames', 'clear']]
  [Driver.Collection.prototype, ['drop', 'create', 'update', 'delete', 'save',
    'ensureIndex', 'dropIndex']]
  [Driver.Cursor.prototype, ['first', 'all', 'next', 'count', 'delete']]
]

for [obj, methods] in objects
  helper.synchronizeMethods obj, methods