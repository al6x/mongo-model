(function() {
  var Model, helper, _;

  _ = require('underscore');

  helper = require('../helper');

  Model = require('./model');

  exports.methods = {
    eq: function(other) {
      return _.isEqual(this, other);
    },
    cache: function() {
      return this._cache || (this._cache = {});
    },
    _setOriginal: function(doc) {
      this._originalDoc = doc;
      return this._originalObj = null;
    },
    _original: function() {
      if (this._originalDoc) {
        return this._originalObj || (this._originalObj = Model._fromMongo(this._originalDoc));
      } else {
        return null;
      }
    },
    set: function(attributes) {
      if (attributes == null) attributes = {};
      _(this).extend(attributes);
      return this;
    },
    safeSet: function(attributes) {
      var _this = this;
      if (attributes == null) attributes = {};
      _(attributes).each(function(v, k) {
        var setterName;
        setterName = "safeSet" + (k.slice(0, 1).toUpperCase()) + k.slice(1, k.length + 1 || 9e9);
        if (setterName in _this) return _this[setterName](v);
      });
      return this;
    }
  };

  exports.classMethods = {
    accessible: function(attr, type) {
      var setterName;
      setterName = "safeSet" + (attr.slice(0, 1).toUpperCase()) + attr.slice(1, attr.length + 1 || 9e9);
      return this.prototype[setterName] = function(v) {
        v = type ? helper.cast(v, type) : v;
        return this[attr] = v;
      };
    },
    timestamps: function() {
      this.before('create', function(callback) {
        this.createdAt = new Date();
        this.updatedAt = new Date();
        return callback();
      });
      return this.before('save', function(callback) {
        this.updatedAt = new Date();
        return callback();
      });
    }
  };

}).call(this);
