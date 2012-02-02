(function() {
  var Driver, sync, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  Driver = require('mongo-model/lib/driver');

  require('mongo-model/lib/driver/sync');

  sync = function() {
    var db, list, units;
    db = Driver.db();
    db.clear();
    units = db.collection('units');
    units.save({
      name: 'Zeratul'
    });
    units.save({
      name: 'Tassadar'
    });
    assert(units.first({
      name: 'Zeratul'
    }).name, 'Zeratul');
    list = units.all({
      name: 'Zeratul'
    });
    assert(_(list).map(function(obj) {
      return obj.name;
    }), ['Zeratul']);
    assert(units.count({
      name: 'Zeratul'
    }), 1);
    assert(units.limit(1).sort({
      name: 1
    }).first().name, 'Tassadar');
    assert(units.find({
      name: 'Zeratul'
    }).count(), 1);
    assert(units.first()._id.constructor, String);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
