(function() {
  var Model, sync, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _ = require('underscore');

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var comment, db, post;
    db = Model.db();
    db.clear();
    global.Post = (function(_super) {

      __extends(Post, _super);

      function Post() {
        Post.__super__.constructor.apply(this, arguments);
      }

      Post.collection('posts');

      Post.validate(function(callback) {
        if (!this.text) {
          this.errors().add({
            text: "can't be empty"
          });
        }
        return callback();
      });

      return Post;

    })(Model);
    post = new Post();
    assert(post.valid(), false);
    assert(post.errors(), {
      text: ["can't be empty"]
    });
    assert(post.save(), false);
    post.text = 'Norad II crashed!';
    assert(post.valid(), true);
    assert(post.save(), true);
    post = new Post();
    assert(post.valid(), false);
    assert(post.save({
      validate: false
    }), true);
    global.Post = (function(_super) {

      __extends(Post, _super);

      Post.collection('posts');

      Post.embedded('comments');

      function Post() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.comments = [];
        Post.__super__.constructor.apply(this, args);
      }

      Post.validate(function(callback) {
        if (!this.text) {
          this.errors().add({
            text: "can't be empty"
          });
        }
        return callback();
      });

      return Post;

    })(Model);
    global.Comment = (function(_super) {

      __extends(Comment, _super);

      function Comment() {
        Comment.__super__.constructor.apply(this, arguments);
      }

      Comment.validate(function(callback) {
        if (!this.text) {
          this.errors().add({
            text: "can't be empty"
          });
        }
        return callback();
      });

      return Comment;

    })(Model);
    post = new Post({
      text: 'Norad II crashed!'
    });
    assert(post.valid(), true);
    comment = new Comment();
    assert(comment.valid(), false);
    post.comments.push(comment);
    assert(post.valid(), false);
    assert(post.save(), false);
    comment.text = "Where?";
    assert(comment.valid(), true);
    assert(post.valid(), true);
    assert(post.save(), true);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
