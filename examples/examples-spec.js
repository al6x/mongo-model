(function() {
  var examples, exec, _;

  _ = require('underscore');

  exec = require('child_process').exec;

  examples = ['assignment', 'associations', 'basics', 'callbacks', 'embedded', 'database', 'driver', 'modifiers', 'queries', 'synchronous', 'validations'];

  describe("Examples", function() {
    return _(examples).each(function(name) {
      return it("should execute '" + name + ".coffee' without errors", function(done) {
        return exec("coffee " + __dirname + "/" + name + ".coffee", function(err, stdout, stderr) {
          if (err || stderr !== "") {
            return done(new Error("example " + name + " is invalid!"));
          }
          return done();
        });
      });
    });
  });

}).call(this);
