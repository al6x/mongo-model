(function() {
  var mongo;

  mongo = require('./driver');

  mongo._db = mongo.db;

  global.$db = null;

  global.withMongo = function(options) {
    if (options == null) options = {};
    mongo.db = function(als, callback) {
      return callback(null, global.$db);
    };
    beforeEach(function(done) {
      global.$db = null;
      return mongo.server(function(err, server) {
        if (err) return done(err);
        return server.db('test', function(err, db) {
          if (err) return done(err);
          return db.clear(function(err) {
            if (err) return done(err);
            global.$db = db;
            return done();
          });
        });
      });
    });
    return afterEach(function() {
      if (global.$db) {
        global.$db.close();
        return global.$db = null;
      }
    });
  };

}).call(this);
