# Domain Model for MongoDB (Node.JS).
#
# [Slides, introduction](presentations/introduction/index.html) (with [video](http://www.youtube.com/watch?v=HB2Bkcgdjms)).
# 
# [Slides from MoscowJS 2012](presentations/moscowjs12/index.html).

# ### Features

# [Models](basics.html) are JavaScript Objects.
class global.Post extends Model
  @collection 'posts'

Post.create text: 'Zerg on Tarsonis!'

#

# Simple and flexible [Queries and Scopes](queries.html).
Post.first status: 'published'
Post.find(status: 'published').sort(createdAt: -1).
  limit(25).all()

#

# [Embedded Models](embedded.html) with [validations](validations.html),
# and [callbacks](callbacks.html).
post.comments = []

comment = new Comment text: "Can't believe it!"
post.comments.push comment

post.save()

#

# [Associations](associations.html), 1 to 1, 1 to N, N to M.
post.comments().create text: "Can't believe it!"

#

# [Callbacks](callback.html) and [Validations](validations.html)
class global.Post extends Model
  @after 'delete', (callback) ->
    @comments().delete callback

#

# Same API for [Driver](driver.html) and Model.
posts = db.collection 'posts'
posts.find(status: 'published').sort(createdAt: -1).
  limit(25).all()

#

# Use it with plain JavaScript and Callbacks or in [synchronous mode](synchronous.html) with Fibers.
Post.first {status: 'published'}, (err, post) ->
  console.log post

console.log Post.first(status: 'published')

# ### Installation
#
#     npm install mongo-model
#
# ### Examples
#
# [Basics](basics.html), [Embedded Models](embedded.html), [Queries and Scopes](queries.html),
# [Validations](validations.html), [Callbacks](callbacks.html), [Associations](associations.html),
# [Attribute Assignment & Mass Assignment](assignment.html), [Upsersts and Modifiers](modifiers.html),
# [Working with Connnections and Databases](database.html), [Optional Synchronous Mode](synchronous.html).
#
# You may also consider using only part of the Model - the [Driver](driver.html). It's independent from
# the Model.
#
# All examples written in **optional** [synchronous](synchronous.html) mode (with Fibers), it's made
# for simplicity and to demonstrate how to use Model with Fibers & CoffeeScript.
#
# Note: Model itself doesn't depends on Fibers or CoffeeScript, **You can use it with plain old JavaScript and
# asynchronous callbacks**.
#
# But, You need to install Fibers, Underscore & CoffeeScript to run examples:
#
#     npm install coffee-script fibers underscore
#
# Next clone project, go to `docs/samples` folder and run any example (I recommend You to start
# with [basics](basics.html)):
#
#     git clone git://github.com/alexeypetrushin/mongo-model.git
#     cd mongo-model/docs/samples
#     coffee basics.coffee
#
# Note: if there will be error like `no coffee command` - try install coffee-script
# as global package `npm install coffee-script -g`.
#
# ### Project
#
# The project is [hosted on GitHub](https://github.com/alexeypetrushin/mongo-model).
# You can report bugs and discuss features
# on the [issues page](https://github.com/alexeypetrushin/mongo-model/issues).