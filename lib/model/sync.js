(function() {
  var Model, helper, methods, obj, objects, _i, _len, _ref;

  Model = require('../model');

  helper = require('../helper');

  require('../driver/sync');

  objects = [[Model.prototype, ['create', 'update', 'delete', 'save', 'reload', 'exists', 'valid']], [Model, ['update', 'create', 'delete', 'exists']]];

  for (_i = 0, _len = objects.length; _i < _len; _i++) {
    _ref = objects[_i], obj = _ref[0], methods = _ref[1];
    helper.synchronizeMethods(obj, methods);
  }

}).call(this);
