(function() {
  var Model, sync,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, tassadar;
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
    tassadar = Unit.create({
      name: 'Tassadar',
      life: 80
    });
    tassadar.update({
      $inc: {
        life: -40
      }
    });
    tassadar.reload();
    assert(tassadar.life, 40);
    Unit.update({
      id: tassadar.id
    }, {
      $inc: {
        life: -20
      }
    });
    tassadar.reload();
    assert(tassadar.life, 20);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
