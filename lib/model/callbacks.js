(function() {
  var helper, _;

  _ = require('underscore');

  helper = require('../helper');

  exports.methods = {
    runCallbacks: function(type, event, callback) {
      var counter, funcs, meta, run, that;
      if (!callback) throw new Error("callback required!");
      meta = this.constructor.callbacks()[event] || ((function() {
        throw new Error("unknown event '" + event + "'!}");
      })());
      funcs = meta[type];
      counter = 0;
      that = this;
      run = function(err, result) {
        var fun;
        if (err) return callback(err);
        if (result === false) {
          if (type === 'before') {
            return callback(null, false);
          } else {
            return callback("can't interrupt 'after' callback!");
          }
        }
        if (counter < funcs.length) {
          fun = funcs[counter];
          counter += 1;
          return fun.apply(that, [run]);
        } else {
          return callback(null, true);
        }
      };
      return run();
    }
  };

  exports.classMethods = {
    _callbacks: {
      validate: {
        before: [],
        after: []
      },
      create: {
        before: [],
        after: []
      },
      update: {
        before: [],
        after: []
      },
      save: {
        before: [],
        after: []
      },
      "delete": {
        before: [],
        after: []
      }
    },
    callbacks: function(clone) {
      if (clone == null) clone = false;
      if (clone) this._callbacks = helper.cloneCallbacks(this._callbacks);
      return this._callbacks;
    },
    before: function(event, callback) {
      var meta;
      if (!callback) throw new Error("callback required!");
      meta = this.callbacks(true)[event] || ((function() {
        throw new Error("unknown event '" + event + "'!}");
      })());
      return meta.before.push(callback);
    },
    after: function(event, callback) {
      var meta;
      if (!callback) throw new Error("callback required!");
      meta = this.callbacks(true)[event] || ((function() {
        throw new Error("unknown event '" + event + "'!}");
      })());
      return meta.after.push(callback);
    }
  };

}).call(this);
