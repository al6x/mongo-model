(function() {
  var Model, helper, _,
    __slice = Array.prototype.slice;

  _ = require('underscore');

  helper = require('../helper');

  Model = require('./model');

  exports.methods = {
    errors: function() {
      return this._errors || (this._errors = new Model.Errors());
    },
    valid: function() {
      var args, callback, embeddedModels, embeddedModelsCache, options, runAfterCallback, runBeforeCallbacks, that, _i;
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), callback = arguments[_i++];
      if (!callback) throw new Error("callback required!");
      options = args[0], embeddedModelsCache = args[1];
      options || (options = {});
      embeddedModels = embeddedModelsCache || this._embeddedModels();
      that = this;
      runBeforeCallbacks = function(next) {
        if (options.callbacks !== false) {
          return that.runCallbacks('before', 'validate', function(err, result) {
            if (err) return callback(err);
            if (result === false) return callback(null, false);
            return next();
          });
        } else {
          return next();
        }
      };
      runAfterCallback = function(valid) {
        if (options.callbacks !== false) {
          return that.runCallbacks('after', 'validate', function(err) {
            if (err) return callback(err);
            return callback(null, valid);
          });
        } else {
          return callback(null, valid);
        }
      };
      return runBeforeCallbacks(function() {
        var valid;
        valid = true;
        return that.runValidations(function(err) {
          var check, counter;
          if (err) return callback(err);
          valid = _.isEmpty(that.errors());
          counter = 0;
          check = function() {
            var data, fun;
            if (counter < embeddedModels.length) {
              data = embeddedModels[counter];
              counter += 1;
              fun = function(err, result) {
                var _base, _name;
                if (err) return callback(err);
                if (!result) {
                  valid = false;
                  (_base = that.errors())[_name = data.attr] || (_base[_name] = []);
                  that.errors()[data.attr].push("is invalid");
                }
                return check();
              };
              return data.model.valid(options, data.embeddedModels, fun);
            } else {
              return runAfterCallback(valid);
            }
          };
          return check();
        });
      });
    },
    runValidations: function(callback) {
      var counter, run, that, validations;
      if (!callback) throw new Error("callback required!");
      helper.clear(this.errors());
      validations = this.constructor.validations();
      counter = 0;
      that = this;
      run = function(err) {
        var validator;
        if (err) return callback(err);
        if (counter < validations.length) {
          validator = validations[counter];
          counter += 1;
          return validator.apply(that, [run]);
        } else {
          return callback(null);
        }
      };
      return run();
    }
  };

  exports.classMethods = {
    _validations: [],
    validations: function(clone) {
      if (clone == null) clone = false;
      if (clone) this._validations = _(this._validations).clone();
      return this._validations;
    },
    validate: function(fun) {
      return this.validations(true).push(fun);
    }
  };

}).call(this);
