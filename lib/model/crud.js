(function() {
  var helper, util, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  util = require('util');

  helper = require('../helper');

  exports.methods = {
    create: function() {
      var callback, embeddedModels, options, runAfterCallback, runBeforeCallbacks, that, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      that = this;
      embeddedModels = this._embeddedModels();
      runBeforeCallbacks = function(next) {
        return that._runCallbacksRecursively('before', 'save', options, embeddedModels, callback, function() {
          return that._runCallbacksRecursively('before', 'create', options, embeddedModels, callback, next);
        });
      };
      runAfterCallback = function(next) {
        return that._runCallbacksRecursively('after', 'create', options, embeddedModels, callback, function() {
          return that._runCallbacksRecursively('after', 'save', options, embeddedModels, callback, function() {
            return callback(null, true);
          });
        });
      };
      return runBeforeCallbacks(function() {
        return that._validate(options, embeddedModels, callback, function() {
          return that.constructor.collection(options, function(err, collection) {
            var doc;
            if (err) return callback(err);
            doc = that.toMongo();
            return collection.create(doc, options, function(err, result) {
              return that._interceptSomeErrors(err, callback, function(err) {
                if (err) return callback(err, false);
                that._saved = true;
                that._id = doc._id;
                that._setOriginal(doc);
                return runAfterCallback();
              });
            });
          });
        });
      });
    },
    _update: function() {
      var callback, embeddedModels, options, runAfterCallback, runBeforeCallbacks, that, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      this._requireSaved();
      that = this;
      embeddedModels = this._embeddedModels();
      runBeforeCallbacks = function(next) {
        return that._runCallbacksRecursively('before', 'save', options, embeddedModels, callback, function() {
          return that._runCallbacksRecursively('before', 'update', options, embeddedModels, callback, next);
        });
      };
      runAfterCallback = function(next) {
        return that._runCallbacksRecursively('after', 'update', options, embeddedModels, callback, function() {
          return that._runCallbacksRecursively('after', 'save', options, embeddedModels, callback, function() {
            return callback(null, true);
          });
        });
      };
      return runBeforeCallbacks(function() {
        return that._validate(options, embeddedModels, callback, function() {
          return that.constructor.collection(options, function(err, collection) {
            var doc;
            if (err) return callback(err);
            doc = that.toMongo();
            return collection.update({
              _id: that._id
            }, doc, options, function(err, result) {
              return that._interceptSomeErrors(err, callback, function(err) {
                if (err) return callback(err);
                that._setOriginal(doc);
                return runAfterCallback();
              });
            });
          });
        });
      });
    },
    "delete": function() {
      var callback, embeddedModels, options, runAfterCallback, runBeforeCallbacks, that, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      this._requireSaved();
      that = this;
      embeddedModels = this._embeddedModels();
      runBeforeCallbacks = function(next) {
        return that._runCallbacksRecursively('before', 'delete', options, embeddedModels, callback, next);
      };
      runAfterCallback = function(next) {
        return that._runCallbacksRecursively('after', 'delete', options, embeddedModels, callback, function() {
          return callback(null, true);
        });
      };
      return runBeforeCallbacks(function() {
        return that._validate(options, embeddedModels, callback, function() {
          return that.constructor.collection(options, function(err, collection) {
            if (err) return callback(err);
            return collection["delete"]({
              _id: that._id
            }, options, function(err, result) {
              return that._interceptSomeErrors(err, callback, function(err) {
                if (err) return callback(err);
                that._setOriginal(null);
                return runAfterCallback();
              });
            });
          });
        });
      });
    },
    save: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (this._saved) {
        return this._update.apply(this, args);
      } else {
        return this.create.apply(this, args);
      }
    },
    reload: function(callback) {
      var _this = this;
      if (!callback) throw new Error("callback required!");
      this._requireSaved();
      return this.constructor.first({
        _id: this._id
      }, function(err, obj) {
        if (!err) {
          if (!obj) {
            throw new Error("can't reload object (" + (util.inspect(_this)) + ")!");
          }
          helper.clear(_this);
          _(_this).extend(obj);
        }
        return callback(err);
      });
    },
    update: function() {
      var args, doc, _ref;
      doc = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return (_ref = this.constructor).update.apply(_ref, [{
        _id: this._id
      }, doc].concat(__slice.call(args)));
    },
    _requireSaved: function() {
      if (!this._id) {
        throw new Error("can't update object without id (" + (util.inspect(this)) + ")!");
      }
      if (!this._saved) {
        throw new Error("can't update not saved object (" + (util.inspect(this)) + ")!");
      }
    },
    _validate: function(options, embeddedModels, callback, next) {
      var fun;
      if (options.validate !== false) {
        fun = function(err, result) {
          if (err) return callback(err);
          if (!result) return callback(null, false);
          return next();
        };
        return this.valid(options, embeddedModels, fun);
      } else {
        return next();
      }
    },
    _runCallbacksRecursively: function(type, event, options, embeddedModels, callback, next) {
      if (options.callbacks !== false) {
        return this.runCallbacks(type, event, function(err, result) {
          var counter, run;
          if (err) return callback(err);
          if (result === false) return callback(null, false);
          counter = 0;
          run = function() {
            var data;
            if (counter < embeddedModels.length) {
              data = embeddedModels[counter];
              counter += 1;
              return data.model._runCallbacksRecursively(type, event, options, data.embeddedModels, callback, run);
            } else {
              return next();
            }
          };
          return run();
        });
      } else {
        return next();
      }
    },
    _interceptSomeErrors: function(err, callback, next) {
      var _base, _ref;
      if (err && ((_ref = err.code) === 11000 || _ref === 11001)) {
        (_base = this.errors()).base || (_base.base = []);
        this.errors().base.push('not unique value');
        return callback(null, false);
      } else {
        return next(err);
      }
    }
  };

  exports.classMethods = {
    build: function(attributes) {
      return new this(attributes);
    },
    create: function() {
      var args, attributes, callback, obj, _i;
      attributes = arguments[0], args = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      obj = this.build(attributes);
      return obj.save.apply(obj, __slice.call(args).concat([function(err, result) {
        if (err) return callback(err);
        return callback(err, obj, result);
      }]));
    },
    update: function() {
      var callback, doc, options, selector, _i,
        _this = this;
      selector = arguments[0], doc = arguments[1], options = 4 <= arguments.length ? __slice.call(arguments, 2, _i = arguments.length - 1) : (_i = 2, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      options = options[0] || {};
      return this.collection(options, function(err, collection) {
        if (err) return callback(err);
        return collection.update(selector, doc, options, callback);
      });
    },
    "delete": function() {
      var args, callback, options, selector, _i, _ref,
        _this = this;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      _ref = [args[0] || {}, args[1] || {}], selector = _ref[0], options = _ref[1];
      return this.collection(options, function(err, collection) {
        return collection["delete"](true, selector, options, callback);
      });
    }
  };

}).call(this);
