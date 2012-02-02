(function() {
  var Model, sync,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, post;
    db = Model.db();
    db.clear();
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

      return Post;

    })(Model);
    global.Comment = (function(_super) {

      __extends(Comment, _super);

      function Comment() {
        Comment.__super__.constructor.apply(this, arguments);
      }

      Comment.prototype.post = function() {
        return this._parent;
      };

      return Comment;

    })(Model);
    post = new Post({
      text: 'Zerg infestation found on Tarsonis!'
    });
    post.comments.push(new Comment({
      text: "I can't believe it."
    }));
    post.save();
    post = Post.first();
    assert(post.comments.constructor, Array);
    assert(post.comments.length, 1);
    assert(post.comments[0].text, "I can't believe it.");
    assert(post.comments[0].post(), post);
    post.comments.push(new Comment({
      text: "Me too, but it's true."
    }));
    post.save();
    post = Post.first();
    assert(post.comments.length, 2);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
