(function() {
  var comment, posts,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  global.Post = (function(_super) {

    __extends(Post, _super);

    function Post() {
      Post.__super__.constructor.apply(this, arguments);
    }

    Post.collection('posts');

    return Post;

  })(Model);

  Post.create({
    text: 'Zerg on Tarsonis!'
  });

  Post.first({
    status: 'published'
  });

  Post.find({
    status: 'published'
  }).sort({
    createdAt: -1
  }).limit(25).all();

  post.comments = [];

  comment = new Comment({
    text: "Can't believe it!"
  });

  post.comments.push(comment);

  post.save();

  post.comments().create({
    text: "Can't believe it!"
  });

  global.Post = (function(_super) {

    __extends(Post, _super);

    function Post() {
      Post.__super__.constructor.apply(this, arguments);
    }

    Post.after('delete', function(callback) {
      return this.comments()["delete"](callback);
    });

    return Post;

  })(Model);

  posts = db.collection('posts');

  posts.find({
    status: 'published'
  }).sort({
    createdAt: -1
  }).limit(25).all();

  Post.first({
    status: 'published'
  }, function(err, post) {
    return console.log(post);
  });

  console.log(Post.first({
    status: 'published'
  }));

}).call(this);
