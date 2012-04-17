(function() {
  var Driver, helper, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  helper = require('../helper');

  Driver = require('./driver');

  module.exports = Driver.Collection = (function() {

    function Collection(nCollection) {
      this.nCollection = nCollection;
      this.name = nCollection.collectionName;
    }

    Collection.prototype.drop = function() {
      var callback, options, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      return this.nCollection.drop(function(err, result) {
        return callback(err, result);
      });
    };

    Collection.prototype.create = function() {
      var callback, obj, options, _i;
      obj = arguments[0], options = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      if (obj && obj._model) {
        options = helper.merge({
          collection: this
        }, options);
        return obj.create(options, callback);
      } else {
        return this._create(obj, options, callback);
      }
    };

    Collection.prototype.update = function() {
      var args, callback, doc, obj, options, selector, _i, _ref, _ref2;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      if (args[0] && args[0]._model) {
        _ref = args, obj = _ref[0], args = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
        options = args[0] || {};
        options = helper.merge({
          collection: this
        }, options);
        return obj.update(options, callback);
      } else {
        _ref2 = args, selector = _ref2[0], doc = _ref2[1], args = 3 <= _ref2.length ? __slice.call(_ref2, 2) : [];
        options = args[0] || {};
        return this._update(selector, doc, options, callback);
      }
    };

    Collection.prototype["delete"] = function() {
      var args, callback, count, cursor, del, obj, options, selector, that, _i, _ref, _ref2, _ref3, _ref4;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      if (args[0] && args[0]._model) {
        _ref = args, obj = _ref[0], args = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
        options = args[0] || {};
        options = helper.merge({
          collection: this
        }, options);
        return obj["delete"](options, callback);
      } else if (args[0] === true) {
        args.shift();
        _ref2 = args, selector = _ref2[0], args = 2 <= _ref2.length ? __slice.call(_ref2, 1) : [];
        options = args[0] || {};
        cursor = this.cursor(selector, options).snapshot();
        _ref3 = [0, this], count = _ref3[0], that = _ref3[1];
        del = function(err, doc) {
          if (err) return callback(err);
          if (!doc) return callback(err, count);
          if (doc._model) {
            return that["delete"](doc, options, function(err, result) {
              if (err) return callback(err);
              if (!result) return callback("can't delete " + doc._id + " model");
              count += 1;
              return cursor.next(del);
            });
          } else {
            return that["delete"]({
              _id: doc._id
            }, options, function(err, result) {
              if (err) return callback(err);
              count += 1;
              return cursor.next(del);
            });
          }
        };
        return cursor.next(del);
      } else {
        _ref4 = args, selector = _ref4[0], args = 2 <= _ref4.length ? __slice.call(_ref4, 1) : [];
        options = args[0] || {};
        return this._delete(selector, options, callback);
      }
    };

    Collection.prototype.save = function() {
      var callback, obj, options, _i;
      obj = arguments[0], options = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      options = options[0] || {};
      if (obj && obj._model) {
        options = helper.merge({
          collection: this
        }, options);
        return obj.save(options, callback);
      } else {
        return this._save(obj, options, callback);
      }
    };

    Collection.prototype.insert = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.create.apply(this, args);
    };

    Collection.prototype.remove = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this["delete"].apply(this, args);
    };

    Collection.prototype._create = function(doc, options, callback) {
      var idGenerated, mongoOptions;
      options = helper.merge({
        safe: Driver.safe
      }, options);
      if (!callback) throw new Error("callback required!");
      if (!doc._id && Driver.generateId) {
        idGenerated = true;
        doc._id = Driver.generateId();
      }
      mongoOptions = helper.cleanOptions(options);
      return this.nCollection.insert(doc, mongoOptions, function(err, result) {
        if (!err) result = result[0];
        if (err && idGenerated) delete doc._id;
        return callback(err, result);
      });
    };

    Collection.prototype._update = function(selector, doc, options, callback) {
      var mongoOptions;
      options = helper.merge({
        safe: Driver.safe
      }, options);
      if (!callback) throw new Error("callback required!");
      options = _(_(doc).keys()).any(function(k) {
        return /^\$/.test(k);
      }) ? helper.merge({
        safe: Driver.safe,
        multi: Driver.multi
      }, options) : helper.merge({
        safe: Driver.safe
      }, options);
      mongoOptions = helper.cleanOptions(options);
      return this.nCollection.update(selector, doc, mongoOptions, function(err, result) {
        return callback(err, result);
      });
    };

    Collection.prototype._delete = function(selector, options, callback) {
      var mongoOptions;
      options = helper.merge({
        safe: Driver.safe
      }, options);
      if (!callback) throw new Error("callback required!");
      mongoOptions = helper.cleanOptions(options);
      return this.nCollection.remove(selector, mongoOptions, function(err, result) {
        return callback(err, result);
      });
    };

    Collection.prototype._save = function(doc, options, callback) {
      var _id;
      if (!callback) throw new Error("callback required!");
      if (_id = doc._id) {
        return this.update({
          _id: _id
        }, doc, options, callback);
      } else {
        return this.create(doc, options, callback);
      }
    };

    Collection.prototype.cursor = function() {
      var args, collectionGetter,
        _this = this;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      collectionGetter = function(cursor, callback) {
        if (!callback) throw new Error("callback required!");
        return callback(null, _this);
      };
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(Driver.Cursor, [collectionGetter].concat(__slice.call(args)), function() {});
    };

    Collection.prototype.find = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.cursor.apply(this, args);
    };

    Collection.prototype.ensureIndex = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.nCollection).ensureIndex.apply(_ref, args);
    };

    Collection.prototype.dropIndex = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.nCollection).dropIndex.apply(_ref, args);
    };

    return Collection;

  })();

  _(['first', 'all', 'next', 'close', 'count', 'each', 'limit', 'skip', 'sort', 'paginate', 'snapshot', 'fields', 'tailable', 'batchSize', 'fields', 'hint', 'explain', 'timeout']).each(function(method) {
    return Driver.Collection.prototype[method] = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = this.cursor())[method].apply(_ref, args);
    };
  });

}).call(this);
