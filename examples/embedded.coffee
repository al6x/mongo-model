# Embedded Models.
#
# Models are just ordinary JavaScript Objects, so You can combine and mix it as You wish.
# The only differences between Main and Embedded Models are:
#
# - Main Model has the `_id` attribute.
# - Embedded Models doesn't have `_id`, but have `_parent` - the reference to the Main Model.
#
# **Note:** if You wish [Callbacks](callbacks.html) and [Validations](validations.html) also works on Embedded
# Models You should explicitly tell about it. By using `@embedded` keyword.
#
# In this example we'll create simple Blog Application and see how to embed Comments into Post.
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # Defining Post.
  class global.Post extends Model
    @collection 'posts'

    # Telling Post that it have Embedded Comments.
    @embedded 'comments'

    # Using plain JS Array as container for Comments.
    constructor: (args...) ->
      @comments = []
      super args...

  # Defining Comment.
  class global.Comment extends Model

    # We need a way to access Post from Comment, every child object has `_parent` reference, let's
    # use it.
    post: -> @_parent

  # Creating Post with Comments and saving it to database.
  post = new Post text: 'Zerg infestation found on Tarsonis!'
  post.comments.push new Comment(text: "I can't believe it.")
  post.save()

  # Retrieving from database.
  post = Post.first()
  assert post.comments.constructor, Array
  assert post.comments.length, 1
  assert post.comments[0].text, "I can't believe it."
  assert post.comments[0].post(), post

  # Adding another comment.
  post.comments.push new Comment(text: "Me too, but it's true.")
  post.save()

  # Reading updated post.
  post = Post.first()
  assert post.comments.length, 2

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...


# ### A little of Theory
#
# I believe good support for Embedded Models is very important - because Complex Documents is one of
# the strongest and most important features of MongoDB. Embedded Documents for MongoDB is the same
# as Relations are for Relational Database.
#
# This [Model](model.html) designed and optimized for working with such complex (also multi-nested) Models.
#
# Embedded Models by itself is very complicated stuff, so, in order to not to complicate it any further -
# I tried to keep API as simple as possible.
#
# There's no special Proxies, Collections or other stuff, only plain JS Objects, Arrays and Hashes.
# So, You can safely combine this simple build blocks as You wish and be confident that all
# this will not blow up at some point of complexity.
#
# In this example we covered how to create and use Embedded Models (Models with Embedded Models).