(function() {
  var Driver, NDriver,
    __slice = Array.prototype.slice;

  NDriver = require('mongodb');

  Driver = require('./driver');

  module.exports = Driver.Server = (function() {

    function Server(host, port, options) {
      host || (host = '127.0.0.1');
      port || (port = 27017);
      options || (options = {});
      this.nServer = new NDriver.Server(host, port, options);
    }

    Server.prototype.db = function() {
      var callback, db, name, options, _i;
      name = arguments[0], options = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      options = options[0] || {};
      if (!callback) throw new Error("callback required!");
      db = new Driver.Db(name, this.nServer, options);
      return db.open(function(err, ndb) {
        return callback(err, db);
      });
    };

    return Server;

  })();

}).call(this);
