# MongoDB Driver (Node.JS).
#
# This driver is a part of [Model](model.html),
# but You can use it on its own, without the Model.
#
# The main goal of Driver is to make MongoDB API simple and intuitive,
# it also changes some defaults, to more apropriate values (can be disabled in config).

# Requiring driver.
_      = require 'underscore'
Driver = require 'mongo-model/lib/driver'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/driver/sync'
sync = ->

  # Connecting to 'default' database and clearing it before starting.
  db = Driver.db()
  db.clear()

  # Getting the `units` collection.
  units = db.collection 'units'

  # Let's create two Heroes.
  units.save name: 'Zeratul'
  units.save name: 'Tassadar'

  # Querying first and all documents matching criteria (there's
  # also `next` method for advanced usage).
  assert units.first(name: 'Zeratul').name, 'Zeratul'
  list = units.all(name: 'Zeratul')
  assert (_(list).map (obj) -> obj.name), ['Zeratul']
  assert units.count(name: 'Zeratul'), 1

  # Query helpers.
  assert units.limit(1).sort(name: 1).first().name, 'Tassadar'
  assert units.find(name: 'Zeratul').count(), 1

  # Instead of default `BSON::ObjectId` id, Dirver generates
  # short and nice random string ids (can be disabled in config).
  assert units.first()._id.constructor, String

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered basics of Driver, if You are interesting
# You can also take a look at [Model](model.html) examples.