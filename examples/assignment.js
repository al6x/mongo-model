(function() {
  var Model, sync,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, user;
    db = Model.db();
    db.clear();
    global.User = (function(_super) {

      __extends(User, _super);

      function User() {
        User.__super__.constructor.apply(this, arguments);
      }

      return User;

    })(Model);
    user = new User();
    user.set({
      name: 'Gordon Freeman',
      age: '28'
    });
    assert([user.name, user.age], ['Gordon Freeman', '28']);
    User.accessible('age', Number);
    User.accessible('name');
    user.safeSet({
      name: 'Gordon Freeman',
      age: '28'
    });
    assert([user.name, user.age], ['Gordon Freeman', 28]);
    user.safeSet({
      password: 'Black Mesa'
    });
    assert(user.password, void 0);
    user.set({
      password: 'Black Mesa'
    });
    assert(user.password, 'Black Mesa');
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
