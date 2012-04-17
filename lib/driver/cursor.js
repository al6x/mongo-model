(function() {
  var Driver, Model, helper, util, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  util = require('util');

  helper = require('../helper');

  Driver = require('./driver');

  Model = null;

  module.exports = Driver.Cursor = (function() {

    function Cursor(collectionGetter, selector, options) {
      var _ref;
      if (selector == null) selector = {};
      if (options == null) options = {};
      _ref = [collectionGetter, selector, options], this.collectionGetter = _ref[0], this.selector = _ref[1], this.options = _ref[2];
    }

    Cursor.prototype.find = function(selector, options) {
      if (selector == null) selector = {};
      if (options == null) options = {};
      selector = helper.merge(this.selector, selector);
      options = helper.merge(this.options, options);
      return new this.constructor(this.collectionGetter, selector, options);
    };

    Cursor.prototype.first = function() {
      var args, callback, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      return this.all.apply(this, __slice.call(args).concat([function(err, docs) {
        var doc;
        if (!err) doc = docs[0] || null;
        return callback(err, doc);
      }]));
    };

    Cursor.prototype.all = function() {
      var args, callback, fun, list, that, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      if (args.length > 0) {
        return this.find.apply(this, args).all(callback);
      } else {
        list = [];
        that = this;
        fun = function(err, doc) {
          if (err) return callback(err);
          if (!doc) return callback(err, list);
          list.push(doc);
          return that.next(fun);
        };
        return this.next(fun);
      }
    };

    Cursor.prototype.each = function() {
      var msg;
      msg = "Don't use `each`, it's not implemented by intention!      In async world there's no much sence of using `each`, because there's no way      to make another async call inside of async each.      Use `first`, `all` (with `limit` and pagination) or `next` for advanced scenario.      If You still want one, it can be easilly done in about 5 lines of code, add it      by Yourself if You really want it.";
      throw new Error(msg);
    };

    Cursor.prototype.next = function(callback) {
      var _this = this;
      if (!callback) throw new Error("callback required!");
      if (this.nCursor) {
        return this._next(callback);
      } else {
        return this.collectionGetter(this, function(err, collection) {
          var options;
          if (err) return callback(err);
          options = helper.cleanOptions(_this.options);
          _this.nCursor || (_this.nCursor = collection.nCollection.find(_this.selector, options));
          return _this._next(callback);
        });
      }
    };

    Cursor.prototype._next = function(callback) {
      var that;
      that = this;
      return this.nCursor.nextObject(function(err, doc) {
        if (err) return callback(err);
        if (doc) {
          if (that.options.object !== false) doc = that._processDoc(doc);
          return callback(err, doc);
        } else {
          that.nCursor = null;
          return callback(err, null);
        }
      });
    };

    Cursor.prototype.close = function(callback) {
      if (!this.nCursor) {
        throw new Error("cursor " + (util.inspect(this.selector)) + " already closed!");
      }
      this.nCursor.close();
      return this.nCursor = null;
    };

    Cursor.prototype.count = function() {
      var args, callback, _i,
        _this = this;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      if (args.length > 0) {
        return this.find.apply(this, args).count(callback);
      } else {
        return this.collectionGetter(this, function(err, collection) {
          if (err) return callback(err);
          return collection.nCollection.count(_this.selector, callback);
        });
      }
    };

    Cursor.prototype["delete"] = function() {
      var args, args2, callback, withCallbacks, _i, _ref,
        _this = this;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      args2 = [];
      if (args[0] === true) {
        withCallbacks = true;
        args.shift();
        args2.push(true);
      }
      if (args.length > 0) {
        args2.push(callback);
        return (_ref = this.find.apply(this, args))["delete"].apply(_ref, args2);
      } else {
        return this.collectionGetter(this, function(err, collection) {
          if (err) return callback(err);
          args2 = args2.concat([_this.selector, _this.options, callback]);
          return collection["delete"].apply(collection, args2);
        });
      }
    };

    Cursor.prototype.limit = function(n) {
      return this.find({}, {
        limit: n
      });
    };

    Cursor.prototype.skip = function(n) {
      return this.find({}, {
        skip: n
      });
    };

    Cursor.prototype.sort = function(arg) {
      return this.find({}, {
        sort: arg
      });
    };

    Cursor.prototype.paginate = function() {
      var args, options, page, perPage;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 2) {
        page = args[0], perPage = args[1];
      } else {
        options = args[0] || {};
        page = helper.safeParseInt(options.page);
        perPage = helper.safeParseInt(options.perPage);
      }
      page || (page = 1);
      perPage || (perPage = Driver.perPage);
      if (perPage > Driver.maxPerPage) perPage = Driver.maxPerPage;
      return this.skip((page - 1) * perPage).limit(perPage);
    };

    Cursor.prototype.snapshot = function() {
      return this.find({}, {
        snapshot: true
      });
    };

    Cursor.prototype.fields = function(arg) {
      return this.find({}, {
        fields: arg
      });
    };

    Cursor.prototype.tailable = function() {
      return this.find({}, {
        tailable: true
      });
    };

    Cursor.prototype.batchSize = function(arg) {
      return this.find({}, {
        batchSize: arg
      });
    };

    Cursor.prototype.fields = function(arg) {
      return this.find({}, {
        fields: arg
      });
    };

    Cursor.prototype.hint = function(arg) {
      return this.find({}, {
        hint: arg
      });
    };

    Cursor.prototype.explain = function(arg) {
      return this.find({}, {
        explain: arg
      });
    };

    Cursor.prototype.fields = function(arg) {
      return this.find({}, {
        fields: arg
      });
    };

    Cursor.prototype.timeout = function(arg) {
      return this.find({}, {
        timeout: arg
      });
    };

    Cursor.prototype._processDoc = function(doc) {
      if (doc && doc._class) {
        Model || (Model = require('../model'));
        doc = Model._fromMongo(doc);
      }
      return doc;
    };

    return Cursor;

  })();

}).call(this);
