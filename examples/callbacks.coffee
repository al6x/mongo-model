global.p = (args...) -> console.log args...


# Callbacks are handy way to execute custom logic at special
# moments of the lifecycle of the [Model](model.html). There are following
# callbacks available:
#
#     before validate
#     after validate
#
#     before save
#     after save
#
#     before create
#     after create
#
#     before update
#     after update
#
#     before delete
#     after delete
#
# There's also two special callbacks:
#
#     afterToMongo
#     afterFromMongo
#
# All these callbacks also available on Embedded Models.
#
# In this example we create Post with embedded Comments and
# generate teasers on it using callbacks.
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # ### Basics

  # Defining Post, its teaser will be generated before it will be saved.
  class global.Post extends Model
    @collection 'posts'

    # Generating teaser.
    @before 'save', (callback) ->
      @teaser = if @text then @text[0..4] else ''
      callback()

  # Creating Post, teaser will be generated when we save it.
  post = new Post text: 'Norad II crashed!'
  assert post.teaser, undefined
  post.save()
  assert post.teaser, 'Norad'

  # ### Embedded Models
  #
  # Callbacks on Embedded Models works the same way. Let's add embedded Comments
  # to Post to see how this works.

  # Defining new version of Post, with comments. We need to add `comments` attribute and
  # tell Post to propagate callbacks to it.
  class global.Post extends Model
    @collection 'posts'

    # Telling Post that it has embedded `comments` attribute and should propagate callbacks
    # to it.
    @embedded 'comments'

    # Initializing comments with empty Array.
    constructor: (args...) ->
      @comments = []
      super args...

  # Creating Comment, teaser of Comment will be generated before it will be saved.
  class global.Comment extends Model

    # Generating teaser.
    @before 'save', (callback) ->
      @teaser = if @text then @text[0..4] else ''
      callback()

  # Creating new post.
  post = new Post text: 'Norad II crashed!'

  # Adding Comment.
  comment = new Comment text: 'Where?'
  post.comments.push comment

  # Saving Post with Embedded Comments.
  assert comment.teaser, undefined
  post.save()
  assert comment.teaser, 'Where'

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered callbacks, its types and how they works on
# the Main and Embedded Models.