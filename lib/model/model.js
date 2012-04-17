(function() {
  var Model, helper, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  helper = require('../helper');

  module.exports = Model = (function() {

    Model.prototype._model = true;

    function Model(attributes) {
      if (attributes) this.set(attributes);
    }

    Model._embedded = [];

    Model.embedded = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      if (args.length === 0) {
        return this._embedded;
      } else {
        return this._embedded = this._embedded.concat(args);
      }
    };

    Model.prototype._embeddedModels = function() {
      var list, that;
      list = [];
      that = this;
      _(this.constructor.embedded()).each(function(k) {
        var obj;
        if (obj = that[k]) {
          if (_.isFunction(obj)) {
            throw new Error("embedded model '" + k + "' can't be a Function!");
          }
          if (obj._model) {
            return list.push({
              model: obj,
              embeddedModels: obj._embeddedModels(),
              attr: k
            });
          } else if (helper.isArray(obj)) {
            return _(obj).each(function(v) {
              if (v._model) {
                return list.push({
                  model: v,
                  embeddedModels: v._embeddedModels(),
                  attr: k
                });
              }
            });
          } else if (helper.isObject(obj)) {
            return _(obj).each(function(v) {
              if (v._model) {
                return list.push({
                  model: v,
                  embeddedModels: v._embeddedModels(),
                  attr: k
                });
              }
            });
          }
        }
      });
      return list;
    };

    return Model;

  })();

}).call(this);
