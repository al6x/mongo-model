(function() {
  var Driver, helper, util, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  util = require('util');

  helper = require('../helper');

  Driver = require('../driver');

  exports.methods = {
    toMongo: function() {
      var hash, that;
      hash = {};
      _(this).each(function(v, k) {
        if (!/^_/.test(k)) return hash[k] = v;
      });
      that = this;
      _(this.constructor.embedded()).each(function(k) {
        var obj, r;
        if (obj = that[k]) {
          if (obj.toMongo) {
            r = obj.toMongo();
          } else if (helper.isArray(obj)) {
            r = [];
            _(obj).each(function(v) {
              v = v.toMongo ? v.toMongo() : v;
              return r.push(v);
            });
          } else if (helper.isObject(obj)) {
            r = {};
            _(obj).each(function(v, k) {
              v = v.toMongo ? v.toMongo() : v;
              return r[k] = v;
            });
          }
          return hash[k] = r;
        }
      });
      if (this._id) hash._id = this._id;
      hash._class = this.constructor.name || ((function() {
        throw new Error("no constructor name for " + (util.inspect(this)) + "!");
      }).call(this));
      if (this.afterToMongo) this.afterToMongo(hash);
      return hash;
    },
    toHash: function() {
      return this.toMongo();
    }
  };

  exports.classMethods = {
    _db: 'default',
    db: function(callback) {
      var name;
      name = this._db || ((function() {
        throw new Error("database for '" + this.name + "' model not specified!");
      }).call(this));
      return Driver.db(name, callback);
    },
    _collection: 'default',
    collection: function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 1) {
        return this._collection = args[0];
      } else {
        return this._getCollection.apply(this, args);
      }
    },
    _getCollection: function(options, callback) {
      var collection,
        _this = this;
      if (!callback) throw new Error("callback required!");
      collection = options.collection || this._collection || ((function() {
        throw new Error("collection for '" + this.name + "' model not specified!");
      }).call(this));
      if (_.isString(collection)) {
        return this.db(function(err, db) {
          if (err) return callback(err);
          if (!db) {
            return callback(new Error("something wrong, got null instead of db!"));
          }
          return db.collection(collection, callback);
        });
      } else {
        return callback(null, collection);
      }
    },
    _fromMongo: function(doc, parent) {
      var klass, obj, that;
      if (!doc._class) return doc;
      klass = this.getClass(doc._class);
      if (klass.fromMongo) {
        return klass.fromMongo(doc, parent);
      } else {
        obj = new klass();
        _(doc).each(function(v, k) {
          return obj[k] = v;
        });
        delete obj._class;
        that = this;
        _(klass.embedded()).each(function(k) {
          var o, r,
            _this = this;
          if (o = doc[k]) {
            if (o._class) {
              r = that._fromMongo(o, obj);
            } else if (helper.isArray(o)) {
              r = [];
              _(o).each(function(v) {
                v = v._class ? that._fromMongo(v, obj) : v;
                return r.push(v);
              });
            } else if (helper.isObject(o)) {
              r = {};
              _(o).each(function(v, k) {
                v = v._class ? that._fromMongo(v, obj) : v;
                return r[k] = v;
              });
            }
          }
          return obj[k] = r;
        });
        if (!parent) obj._saved = true;
        obj._setOriginal(doc);
        if (parent) obj._parent = parent;
        if (obj.afterFromMongo) obj.afterFromMongo(doc);
        return obj;
      }
    },
    getClass: function(name) {
      var _ref;
      return ((_ref = global.Models) != null ? _ref[name] : void 0) || global[name] || ((function() {
        throw new Error("can't get '" + name + "' class!");
      })());
    }
  };

}).call(this);
