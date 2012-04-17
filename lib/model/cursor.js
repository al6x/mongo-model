(function() {
  var Driver, Model, helper, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  _ = require('underscore');

  helper = require('../helper');

  Driver = require('../driver');

  Model = require('./model');

  module.exports = Model.Cursor = (function(_super) {

    __extends(Cursor, _super);

    function Cursor(model, collectionGetter, selector, options) {
      var _ref;
      if (selector == null) selector = {};
      if (options == null) options = {};
      _ref = [model, collectionGetter, selector, options], this.model = _ref[0], this.collectionGetter = _ref[1], this.selector = _ref[2], this.options = _ref[3];
    }

    Cursor.prototype.find = function(selector, options) {
      if (selector == null) selector = {};
      if (options == null) options = {};
      selector = helper.merge(this.selector, selector);
      options = helper.merge(this.options, options);
      return new this.constructor(this.model, this.collectionGetter, selector, options);
    };

    Cursor.prototype.build = function(attributes) {
      if (attributes == null) attributes = {};
      attributes = helper.merge(this.selector, attributes);
      return this.model.build(attributes);
    };

    Cursor.prototype.create = function(attributes) {
      if (attributes == null) attributes = {};
      attributes = helper.merge(this.selector, attributes);
      return this.model.create(attributes);
    };

    return Cursor;

  })(Driver.Cursor);

}).call(this);
