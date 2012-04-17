(function() {
  var Model, helper,
    __slice = Array.prototype.slice;

  helper = require('../helper');

  Model = require('./model');

  module.exports = Model.Errors = (function() {

    function Errors() {}

    return Errors;

  })();

  helper.definePropertyWithoutEnumeration(Model.Errors.prototype, 'add', function() {
    var args, attr, message, _ref, _results;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (args.length === 1) {
      _ref = args[0];
      _results = [];
      for (attr in _ref) {
        message = _ref[attr];
        _results.push(this.add(attr, message));
      }
      return _results;
    } else {
      attr = args[0], message = args[1];
      this[attr] || (this[attr] = []);
      return this[attr].push(message);
    }
  });

}).call(this);
