(function() {
  var Model, sync, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _ = require('underscore');

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, list, tassadar, zeratul;
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
    global.Stats = (function(_super) {

      __extends(Stats, _super);

      function Stats() {
        Stats.__super__.constructor.apply(this, arguments);
      }

      return Stats;

    })(Model);
    zeratul = new Unit({
      name: 'Zeratul',
      status: 'alive'
    });
    zeratul.stats = new Stats({
      attack: 85,
      life: 300,
      shield: 100
    });
    tassadar = new Unit({
      name: 'Tassadar',
      status: 'dead'
    });
    tassadar.stats = new Stats({
      attack: 0,
      life: 80,
      shield: 300
    });
    assert(zeratul.save(), true);
    assert(tassadar.save(), true);
    tassadar.stats.attack = 20;
    assert(tassadar.save(), true);
    assert(Unit.first({
      name: 'Zeratul'
    }).name, 'Zeratul');
    list = Unit.all({
      name: 'Zeratul'
    });
    assert(_(list).map(function(obj) {
      return obj.name;
    }), ['Zeratul']);
    assert(Unit.limit(1).sort({
      name: 1
    }).first().name, 'Tassadar');
    assert(Unit.find({
      name: 'Zeratul'
    }).count(), 1);
    assert(Unit.first()._id.constructor, String);
    assert(Unit.first().toHash().name, 'Zeratul');
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
