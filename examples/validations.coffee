# Validations in [Model](model.html).
#
# You can use `errors` to store error messages, `valid` to check validity of Model and `validate`,
# `before validate` and 'after validate` callbacks for defining validation rules.
#
# In this example we'll create simple Blog Application and
# use validations to ensure correctness of Post and Comments.
_     = require 'underscore'
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # ### Basics
  #
  # Defining Post and requiring presence of text attribute.
  class global.Post extends Model
    @collection 'posts'

    @validate (callback) ->
      @errors().add 'text', "can't be empty" unless @text
      callback()

  # Creating post, it can't be saved because its text is empty and it's invalid.
  post = new Post()
  assert post.valid(), false
  assert post.errors(), {text: ["can't be empty"]}
  assert post.save(), false

  # Let's add text to it so it will be valid and we can save it.
  post.text = 'Norad II crashed!'
  assert post.valid(), true
  assert post.save(), true

  # Usually when model is invalid it can't be saved, but if You need You can skip
  # validation and save invalid model.
  post = new Post()
  assert post.valid(), false
  assert post.save(validate: false), true

  # ### Embedded Models
  #
  # MongoDB encourage to use Embedded Models a lot, so it's important
  # to provide validations for it.
  #
  # Defining Post with embedded Comments.
  class global.Post extends Model
    @collection 'posts'
    @embedded 'comments'

    constructor: (args...) ->
      @comments = []
      super args...

    @validate (callback) ->
      @errors().add 'text', "can't be empty" unless @text
      callback()

  # Defining Comment.
  class global.Comment extends Model
    @validate (callback) ->
      @errors().add 'text', "can't be empty" unless @text
      callback()

  # Creating valid Post.
  post = new Post text: 'Norad II crashed!'
  assert post.valid(), true

  # Creating invalid Comment with empty text.
  comment = new Comment()
  assert comment.valid(), false

  # Validation of Main Model also runs Validations on all its Embedded Models,
  # so adding invalid Comment to valid Post will make Post also invalid.
  post.comments.push comment
  assert post.valid(), false
  assert post.save(), false

  # In order to save Post we need to make the Comment valid.
  comment.text = "Where?"
  assert comment.valid(), true
  assert post.valid(), true
  assert post.save(), true

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# ### Predefined validations
#
# In example before we covered custom validations, but usually in 90% of cases You need only
# a small set of simple validations, and it would be really handy if there will be helpers like this:
#
#     validatesFormatOf
#     validatesLengthOf
#     validatesNumericalityOf
#     validatesAcceptanceOf
#     validatesConfirmationOf
#     validatesPresenceOf
#     validatesTrueFor
#     validatesExclusionOf
#     validatesInclusionOf
#
# But sadly, there's no such Validation library in JavaScript right now. And I feel that it would be wrong
# to reinvent a bycicle and implement this stuff directly in Model.
# I believe it should be implemented as a completely standalone library.
#
# So, right now predefined validations aren't available, but it's important feature and I'm looking for a ways to
# implemente it. Probably it will be available in the next versions.