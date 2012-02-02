(function() {
  var Model, sync, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  _ = require('underscore');

  Model = require('mongo-model');

  require('mongo-model/lib/sync');

  sync = function() {
    var comment, db, list, perPage, post;
    db = Model.db();
    db.clear();
    global.Post = (function(_super) {

      __extends(Post, _super);

      Post.collection('posts');

      function Post() {
        var args;
        args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        this.commentsCount = 0;
        Post.__super__.constructor.apply(this, args);
      }

      Post.prototype.comments = function() {
        return Comment.find({
          postId: this._id
        });
      };

      Post.prototype.inspect = function() {
        return "{Post: " + this.text + "}";
      };

      return Post;

    })(Model);
    global.Comment = (function(_super) {

      __extends(Comment, _super);

      function Comment() {
        Comment.__super__.constructor.apply(this, arguments);
      }

      Comment.collection('comments');

      Comment.prototype.setPost = function(post) {
        this.postId = post._id;
        return this.cache().post = post;
      };

      Comment.prototype.post = function() {
        var _base;
        return (_base = this.cache()).post || (_base.post = Post.first({
          _id: this.postId
        }));
      };

      Comment.prototype.inspect = function() {
        return "{Comment: " + this.text + "}";
      };

      return Comment;

    })(Model);
    post = Post.create({
      text: 'Zerg infestation found on Tarsonis!'
    });
    post.comments().create({
      text: "I can't believe it."
    });
    post = Post.first();
    assert(post.text, 'Zerg infestation found on Tarsonis!');
    assert(post.comments().count(), 1);
    assert(post.comments().first().text, "I can't believe it.");
    assert(post.comments().first().post(), post);
    comment = new Comment({
      text: "Me too, but it's true."
    });
    comment.setPost(post);
    comment.save();
    assert(post.comments().count(), 2);
    perPage = 2;
    list = post.comments().paginate(1, perPage).all();
    assert(_(list).map(function(obj) {
      return obj.text;
    }), ["I can't believe it.", "Me too, but it's true."]);
    Post.after('delete', function(callback) {
      return this.comments()["delete"](true, callback);
    });
    post["delete"]();
    assert(Comment.count(), 0);
    Comment.after('create', function(callback) {
      return Post.update({
        _id: this.postId
      }, {
        $inc: {
          commentsCount: 1
        }
      }, callback);
    });
    Comment.after('delete', function(callback) {
      return Post.update({
        _id: this.postId
      }, {
        $inc: {
          commentsCount: -1
        }
      }, callback);
    });
    post = Post.create({
      text: 'Zerg infestation found on Tarsonis!'
    });
    post.comments().create({
      text: "I can't believe it."
    });
    post.reload();
    assert(post.commentsCount, 1);
    post.comments()["delete"](true);
    post.reload();
    assert(post.commentsCount, 0);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
