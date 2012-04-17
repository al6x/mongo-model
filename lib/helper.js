(function() {
  var util, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  util = require('util');

  module.exports = {
    isArray: function(obj) {
      return Array.isArray(obj);
    },
    isObject: function(obj) {
      return Object.prototype.toString.call(obj) === "[object Object]";
    },
    merge: function(to, from) {
      return _(_(to).clone()).extend(from);
    },
    safeParseInt: function(v) {
      if (_.isNumber(v)) v = v.toString();
      if (!_.isString(v)) return null;
      if (v.length > 20) return null;
      if (!(v.length > 0)) return null;
      return parseInt(v);
    },
    cleanOptions: function(options) {
      var list, option, _i, _len;
      list = ['db', 'collection', 'object', 'validate', 'callbacks', 'cache'];
      options = _(options).clone();
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        option = list[_i];
        delete options[option];
      }
      return options;
    },
    clear: function(obj) {
      return _(obj).each(function(v, k) {
        return delete obj[k];
      });
    },
    cast: function(v, type) {
      var casted, tmp;
      type || (type = String);
      casted = (function() {
        if (type === String) {
          return v.toString();
        } else if (type === Number) {
          if (_.isNumber(v)) {
            return v;
          } else if (_.isString(v)) {
            tmp = parseInt(v);
            if (_.isNumber(tmp)) return tmp;
          }
        } else if (type === Boolean) {
          if (_.isBoolean(v)) {
            return v;
          } else if (_.isString(v)) {
            return v === 'true';
          }
        } else if (type === Date) {
          if (_.isDate(v)) {
            return v;
          } else if (_.isString(v)) {
            tmp = new Date(v);
            if (_.isDate(tmp)) return tmp;
          }
        } else {
          throw new Error("can't cast, unknown type (" + (util.inspect(type)) + ")!");
        }
      })();
      if (casted == null) {
        throw new Error("can't cast, invalid value (" + (util.inspect(v)) + ")!");
      }
      return casted;
    },
    cloneCallbacks: function(callbacks) {
      var clone;
      clone = {};
      _(callbacks).each(function(v, k) {
        clone[k] = {};
        return _(v).each(function(v2, k2) {
          return clone[k][k2] = _(v2).clone();
        });
      });
      return clone;
    },
    synchronize: function(fn) {
      var Future;
      try {
        Future = require('fibers/future');
      } catch (e) {
        console.log("WARN:\n  You are trying to use mongo-model in synchronous mode.\n  Synchronous mode is optional and requires additional `fibers` library.\n  It seems that there's no such library in Your system.\n  Please install it with `npm install fibers`.");
        throw e;
      }
      return function() {
        var args, future, last;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        last = _(args).last();
        if (Fiber.current && (!last || !_.isFunction(last))) {
          future = new Future();
          args.push(future.resolver());
          fn.apply(this, args);
          return future.wait();
        } else {
          return fn.apply(this, args);
        }
      };
    },
    synchronizeMethods: function(obj, methods) {
      var method, name, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = methods.length; _i < _len; _i++) {
        name = methods[_i];
        method = obj[name] || ((function() {
          throw new Error("no method " + name + " in " + (util.inspect(obj)) + "!");
        })());
        _results.push(obj[name] = this.synchronize(method));
      }
      return _results;
    },
    definePropertyWithoutEnumeration: function(obj, name, value) {
      return Object.defineProperty(obj, name, {
        enumerable: false,
        writable: true,
        configurable: true,
        value: value
      });
    }
  };

}).call(this);
