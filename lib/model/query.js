(function() {
  var Model, helper, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  helper = require('../helper');

  Model = require('./model');

  exports.methods = {
    exists: function() {
      var callback, options, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      options = options[0] || {};
      return this.constructor.exists({
        _id: this._id
      }, options, callback);
    }
  };

  exports.classMethods = {
    cursor: function() {
      var args, collectionGetter,
        _this = this;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      collectionGetter = function(cursor, callback) {
        if (!callback) throw new Error("callback required!");
        return _this.collection(cursor.options, callback);
      };
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(Model.Cursor, [this, collectionGetter].concat(__slice.call(args)), function() {});
    },
    find: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.cursor.apply(this, args);
    },
    exists: function() {
      var args, callback, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      return this.count.apply(this, __slice.call(args).concat([function(err, result) {
        if (err) return callback(err);
        return callback(null, result > 0);
      }]));
    }
  };

  _(['first', 'all', 'next', 'close', 'count', 'each', 'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable', 'batchSize', 'fields', 'hint', 'explain', 'timeout']).each(function(method) {
    return exports.classMethods[method] = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.cursor())[method].apply(_ref, args);
    };
  });

}).call(this);
