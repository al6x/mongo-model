(function() {
  var Model, sync, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _ = require('underscore');

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, jim, list, perPage, tassadar, units, zeratul;
    db = Model.db();
    db.clear();
    global.Unit = (function(_super) {

      __extends(Unit, _super);

      function Unit() {
        Unit.__super__.constructor.apply(this, arguments);
      }

      Unit.collection('units');

      return Unit;

    })(Model);
    zeratul = Unit.create({
      name: 'Zeratul',
      race: 'Protoss',
      status: 'alive'
    });
    tassadar = Unit.create({
      name: 'Tassadar',
      race: 'Protoss',
      status: 'dead'
    });
    jim = Unit.create({
      name: 'Jim',
      race: 'Terran',
      status: 'alive'
    });
    assert(Unit.first({
      name: 'Zeratul'
    }).name, 'Zeratul');
    list = Unit.all({
      name: 'Zeratul'
    });
    assert(_(list).map(function(obj) {
      return obj.name;
    }), ['Zeratul']);
    assert(Unit.count(), 3);
    assert(Unit.count({
      race: 'Protoss'
    }), 2);
    assert(Unit.exists({
      name: 'Zeratul'
    }), true);
    assert(zeratul.exists(), true);
    Unit.all({
      race: 'Protoss'
    }, {
      sort: {
        name: -1
      },
      limit: 1
    });
    Unit.find({
      race: 'Protoss'
    }).sort({
      name: -1
    }).limit(1).all();
    global.Unit = (function(_super) {

      __extends(Unit, _super);

      function Unit() {
        Unit.__super__.constructor.apply(this, arguments);
      }

      Unit.collection('units');

      Unit.alive = function() {
        return this.find({
          status: 'alive'
        });
      };

      return Unit;

    })(Model);
    assert(Unit.alive().count(), 2);
    assert(Unit.alive().find({
      name: 'Zeratul'
    }).first().name, 'Zeratul');
    perPage = 2;
    list = Unit.paginate(1, perPage).sort({
      name: 1
    }).all();
    assert(_(list).map(function(obj) {
      return obj.name;
    }), ['Jim', 'Tassadar']);
    list = Unit.paginate(2, perPage).sort({
      name: 1
    }).all();
    assert(_(list).map(function(obj) {
      return obj.name;
    }), ['Zeratul']);
    units = db.collection('units');
    assert(units.first({
      name: 'Jim'
    }).name, 'Jim');
    assert(units.first({
      name: 'Jim'
    }).constructor, Unit);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
