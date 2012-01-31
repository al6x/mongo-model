# Modelling Associations for [Model](model.html).
#
# MongoDB is Document Database, and unlike Relational Database its key
# feature is Embedded Documents. It also support Associations but
# there are some limitations.
#
# So, with MongoDB You usually use Embedded Documents a lot and Associations not so much.
#
# According to this Mongo Model provides You with advanced tools
# for [Embedded Models](embedded.html), and basic only for modelling Associations.
#
# In this example we'll create simple Blog Application and see how to associate
# Comments with the Post using one-to-many association (take a look at the [embedded](embedded.html) example
# to see how to embed Comments into Post).
_     = require 'underscore'
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # Defining Post.
  class global.Post extends Model
    # Storing post in `posts` collection.
    @collection 'posts'

    # Set up some defaults.
    constructor: (args...) ->
      @commentsCount = 0
      super args...

    # Creating and returning [Cursor](queries) that can be used
    # later to select comments belongign to this post (there's no
    # database call at this point).
    comments: ->
      Comment.find postId: @_id

    inspect: -> "{Post: #{@text}}"

  # Defining Comment.
  class global.Comment extends Model
    # Storing comment in `comments` collection.
    @collection 'comments'

    # Adding method allowing to assign Post to Comment.
    setPost: (post) ->
      @postId = post._id
      @cache().post = post

    # Retrieving the Post this Comment belongs to.
    post: ->
      @cache().post ||= Post.first _id: @postId

    inspect: -> "{Comment: #{@text}}"

  # Creating Post with Comments and saving it to database.
  post = Post.create text: 'Zerg infestation found on Tarsonis!'
  post.comments().create text: "I can't believe it."

  # Retrieving post and comments.
  post = Post.first()
  assert post.text, 'Zerg infestation found on Tarsonis!'
  assert post.comments().count(), 1
  assert post.comments().first().text, "I can't believe it."
  assert post.comments().first().post(), post

  # You can also add comments directly, without helpers.
  comment = new Comment text: "Me too, but it's true."
  comment.setPost post
  comment.save()
  assert post.comments().count(), 2

  # Comments belonging to post are returned as [Cursor](queries.html)
  # thus giving You access to all kind of operations.
  perPage = 2
  list = post.comments().paginate(1, perPage).all()
  assert (_(list).map (obj) -> obj.text), [
    "I can't believe it."
    "Me too, but it's true."
  ]

  # ### Deleting all dependent Comments.
  #
  # If the post will be deleted, all comments also should be deleted, let's
  # implemet this.
  #
  # **Note:** Theoretically synchronous version should look something like this:
  #
  #     _(@comments().all()).each (c) -> c.delete()
  #
  # But right now it doesn't works, some strange issue with Fibers, somehow
  # `Fiber.current` in here returns `undefined`, don't know why.
  #
  # If You do know why this happens please share Your knowledge on the project's
  # [issues](https://github.com/alexeypetrushin/mongo-model/issues) page.
  #
  # So far we'll be using this asynchronous code.
  Post.after 'delete', (callback) ->
    @comments().delete true, callback

  # After deleting the post all dependent comments also should be deleted.
  post.delete()
  assert Comment.count(), 0

  # ### Caching comments count.
  #
  # It would be nice to know how many comments does the post have withoug
  # executing additional query to count it, let's do this by caching it in
  # the `commentsCount` attribute of the Post.
  #
  # We need to update `commentsCount` attribute every time comment created and deleted.
  # We can do this by retrieving, updating and then saving the Post, but let's
  # do it in more efficient way, by using [modifiers](modifiers.html).
  Comment.after 'create', (callback) ->
    Post.update {_id: @postId}, {$inc: {commentsCount: 1}}, callback

  Comment.after 'delete', (callback) ->
    Post.update {_id: @postId}, {$inc: {commentsCount: -1}}, callback

  # Now, every time Comment will be created or deleted, Post `commentsCount`
  # attribute will be updated accordingly.
  post = Post.create text: 'Zerg infestation found on Tarsonis!'
  post.comments().create text: "I can't believe it."
  post.reload()
  assert post.commentsCount, 1
  post.comments().delete(true)
  post.reload()
  assert post.commentsCount, 0

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered 1-to-N association, but You can implement all
# other types using similar technics (the only complex case is
# M-to-N - use array of ids to do it).
#
# Also, remember that MongoDB is Document Database, not Relational.
# If You want to get most of it – use Embedded Documents whenever possible,
# avoid Associations and use it only if You really need it.