(function() {
  var Model,
    __slice = Array.prototype.slice;

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

  Fiber(function() {
    var db, units;
    db = Model.db();
    db.clear();
    units = db.collection('units');
    units.save({
      name: 'Zeratul'
    });
    assert(units.first({
      name: 'Zeratul'
    }).name, 'Zeratul');
    return db.close();
  }).run();

  Model.db(function(err, db) {
    if (err) throw err;
    return db.clear(function(err) {
      if (err) throw err;
      return db.collection('units', function(err, units) {
        if (err) throw err;
        return units.save({
          name: 'Zeratul'
        }, function(err, result) {
          if (err) throw err;
          return units.first({
            name: 'Zeratul'
          }, function(err, unit) {
            if (err) throw err;
            assert(unit.name, 'Zeratul');
            return db.close();
          });
        });
      });
    });
  });

  Fiber(function() {
    var db;
    db = Model.db();
    db.clear();
    return db.collection('units', function(err, units) {
      units.save({
        name: 'Zeratul'
      });
      assert(units.first({
        name: 'Zeratul'
      }).name, 'Zeratul');
      return db.close();
    });
  }).run();

}).call(this);
