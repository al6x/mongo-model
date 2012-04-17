(function() {
  var Driver, helper, methods, obj, objects, _i, _len, _ref;

  Driver = require('../driver');

  helper = require('../helper');

  objects = [[Driver, ['db']], [Driver.Server.prototype, ['db']], [Driver.Db.prototype, ['collection', 'open', 'collectionNames', 'clear']], [Driver.Collection.prototype, ['drop', 'create', 'update', 'delete', 'save', 'ensureIndex', 'dropIndex']], [Driver.Cursor.prototype, ['first', 'all', 'next', 'count', 'delete']]];

  for (_i = 0, _len = objects.length; _i < _len; _i++) {
    _ref = objects[_i], obj = _ref[0], methods = _ref[1];
    helper.synchronizeMethods(obj, methods);
  }

}).call(this);
