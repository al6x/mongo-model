(function() {
  var Model, _;

  _ = require('underscore');

  Model = require('./model/model');

  module.exports = Model;

  require('./model/cursor');

  require('./model/errors');

  _(['crud', 'persistence', 'query', 'validation', 'callbacks', 'misc']).each(function(name) {
    var mod;
    mod = require("./model/" + name);
    _(Model.prototype).extend(mod.methods);
    if (mod.classMethods) return _(Model).extend(mod.classMethods);
  });

}).call(this);
