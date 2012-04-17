(function() {
  var Driver, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  module.exports = Driver = {
    safe: true,
    multi: true,
    idSize: 6,
    idSymbols: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(''),
    generateId: function() {
      var count, id, rand, _ref;
      _ref = ["", this.idSize + 1], id = _ref[0], count = _ref[1];
      while (count -= 1) {
        rand = Math.floor(Math.random() * this.idSymbols.length);
        id += this.idSymbols[rand];
      }
      return id;
    },
    perPage: 25,
    maxPerPage: 100,
    configure: function(options) {
      return _(this).extend(options);
    },
    server: function() {
      var args, callback, server;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (_.isFunction(_(args).last())) callback = args.pop();
      server = (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(Driver.Server, args, function() {});
      process.nextTick(function() {
        if (callback) return callback(null, server);
      });
      return server;
    },
    db: function() {
      var callback, db, dbAlias, dbName, dbOptions, server, _i, _ref,
        _this = this;
      dbAlias = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      dbAlias = dbAlias[0] || 'default';
      if (!callback) throw new Error("callback required!");
      this.dbCache || (this.dbCache = {});
      if (db = this.dbCache[dbAlias]) {
        return callback(null, db);
      } else {
        dbOptions = ((_ref = this.databases) != null ? _ref[dbAlias] : void 0) || {};
        server = this.server(dbOptions.host, dbOptions.port, dbOptions.options);
        dbName = dbOptions.name || 'default';
        return server.db(dbName, function(err, db) {
          if (err) return callback(err);
          if (dbOptions.username) {
            return db.authenticate(dbOptions.username, dbOptions.password, function(err, db) {
              if (err) return callback(err);
              this.dbCache[dbAlias] = db;
              return callback(null, db);
            });
          } else {
            _this.dbCache[dbAlias] = db;
            return callback(null, db);
          }
        });
      }
    }
  };

}).call(this);
