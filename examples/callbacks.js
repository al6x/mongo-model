(function() {
  var Model, sync,
    __slice = Array.prototype.slice,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  global.p = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return console.log.apply(console, args);
  };

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

      Post.before('save', function(callback) {
        this.teaser = this.text ? this.text.slice(0, 5) : '';
        return callback();
      });

      return Post;

    })(Model);
    post = new Post({
      text: 'Norad II crashed!'
    });
    assert(post.teaser, void 0);
    post.save();
    assert(post.teaser, 'Norad');
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

      Comment.before('save', function(callback) {
        this.teaser = this.text ? this.text.slice(0, 5) : '';
        return callback();
      });

      return Comment;

    })(Model);
    post = new Post({
      text: 'Norad II crashed!'
    });
    comment = new Comment({
      text: 'Where?'
    });
    post.comments.push(comment);
    assert(comment.teaser, void 0);
    post.save();
    assert(comment.teaser, 'Where');
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
