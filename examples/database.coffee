# Configuring and using multiple Collections and Databases with [Model](model.html).
#
# *This is advanced topic, You can safely ignore it if You don't need such things.*
#
# By default Models use the `default` Database Alias (Alias, not the actual Database name!),
# but You can use multiple Databases and save any Model to any Database and Collection.
#
# In this example we'll setup Database Aliases, create Post and save it to multiple Databases and Collections.
Model = require 'mongo-model'
Driver = require 'mongo-model/lib/driver'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # ### Connections, Database Aliases and Configuration
  #
  # In real-life scenario it's not very convinient to use real Database name
  # in Application, usually it's more convinient to use Aliases and specify connection details in config.
  #
  # You can cofigure Aliases in Driver, in this code the `blog` is an Alias for the `blog_development` database.
  Driver.configure
    databases:
      blog:
        name: 'blog_development'
      default:
        name: 'default_development'
        host: 'localhost'

  # Connecting to default database and clearing it before starting.
  db = Model.db 'default'
  db.clear()

  # The `default` is the logical Alias, the actual name of database is different.
  assert db.name, 'default_development'

  # ### Saving Model to any Collection

  # Defining Post.
  class global.Post extends Model
    # By default, if not explicitly specified it will be saved to `default` Database.
    @db 'default'

    # By default, if not explicitly specified it also will be saved to the `post` Collection.
    @collection 'posts'

  # Creating post in `default.posts` Collection.
  post = new Post text: 'Zerg infestation found on Tarsonis!'
  post.save()
  posts = db.collection 'posts'
  assert posts.count(), 1

  # Saving post to other Collection.
  drafts = db.collection 'drafts'
  post = new Post text: 'Norad II crashed!'
  post.save collection: drafts
  assert drafts.count(), 1

  # You can also directly save any Model to any Database and Collection.
  post = new Post text: 'Protoss Cruiser approaching Tarsonis!'
  drafts.save post
  assert drafts.count(), 2

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...