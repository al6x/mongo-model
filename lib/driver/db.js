(function() {
  var Driver, NDriver, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  NDriver = require('mongodb');

  Driver = require('./driver');

  module.exports = Driver.Db = (function() {

    function Db(name, nServer, options) {
      if (options == null) options = {};
      this.name = name;
      this.nDb = new NDriver.Db(name, nServer, options);
    }

    Db.prototype.collection = function() {
      var callback, name, options, _i,
        _this = this;
      name = arguments[0], options = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      return this.nDb.collection(name, options, function(err, nCollection) {
        var collection;
        if (!err) collection = new Driver.Collection(nCollection);
        return callback(err, collection);
      });
    };

    Db.prototype.open = function() {
      var callback, options, _i,
        _this = this;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      return this.nDb.open(function(err, nDb) {
        return callback(err, _this);
      });
    };

    Db.prototype.close = function() {
      return this.nDb.close();
    };

    Db.prototype.collectionNames = function() {
      var callback, dbName, options, _i;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      dbName = this.name;
      return this.nDb.collectionNames(function(err, names) {
        names = _(names).map(function(obj) {
          if (!err) return obj.name.replace("" + dbName + ".", '');
        });
        return callback(err, names);
      });
    };

    Db.prototype.clear = function() {
      var callback, options, _i,
        _this = this;
      options = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      return this.collectionNames(options, function(err, names) {
        var counter, drop;
        if (err) return callback(err);
        names = _(names).select(function(name) {
          return !/^system\./.test(name);
        });
        counter = 0;
        drop = function() {
          var name;
          if (counter === names.length) {
            return callback(null);
          } else {
            name = names[counter];
            counter += 1;
            return _this.collection(name, options, function(err, collection) {
              if (err) return callback(err);
              return collection.drop(function(err) {
                return drop(err);
              });
            });
          }
        };
        return drop();
      });
    };

    Db.prototype.authenticate = function(username, password, callback) {
      var _this = this;
      if (!callback) throw new Error("callback required!");
      return this.nDb.authenticate(username, password, function(err, success) {
        if (err) return callback(err);
        if (!success) {
          return callback(new Error("Could not authenticate user " + username));
        }
        return callback(null, _this);
      });
    };

    return Db;

  })();

}).call(this);
