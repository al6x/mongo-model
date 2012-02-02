(function() {
  var Driver, Model, sync,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  Model = require('mongo-model');

  Driver = require('mongo-model/lib/driver');

  require('mongo-model/lib/sync');

  sync = function() {
    var db, drafts, post, posts;
    Driver.configure({
      databases: {
        blog: {
          name: 'blog_development'
        },
        "default": {
          name: 'default_development',
          host: 'localhost'
        }
      }
    });
    db = Model.db('default');
    db.clear();
    assert(db.name, 'default_development');
    global.Post = (function(_super) {

      __extends(Post, _super);

      function Post() {
        Post.__super__.constructor.apply(this, arguments);
      }

      Post.db('default');

      Post.collection('posts');

      return Post;

    })(Model);
    post = new Post({
      text: 'Zerg infestation found on Tarsonis!'
    });
    post.save();
    posts = db.collection('posts');
    assert(posts.count(), 1);
    drafts = db.collection('drafts');
    post = new Post({
      text: 'Norad II crashed!'
    });
    post.save({
      collection: drafts
    });
    assert(drafts.count(), 1);
    post = new Post({
      text: 'Protoss Cruiser approaching Tarsonis!'
    });
    drafts.save(post);
    assert(drafts.count(), 2);
    return db.close();
  };

  Fiber(sync).run();

  global.assert = function() {
    var args, _ref;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return (_ref = require('assert')).deepEqual.apply(_ref, args);
  };

}).call(this);
