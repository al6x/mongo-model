# Basic example for [Model](model.html).
#
# In this example we'll create simple Model and examine basic CRUD and
# querying operations.
_     = require 'underscore'
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # ### Defining Model

  # Let's define a game Unit.
  #
  # Models are (almost) just plain JavaScript Objects, there's no any Attribute Scheme,
  # Types, Proxies, or other complex stuff. Just simple objects and arrays, use standard
  # JS practices for working with it.
  #
  # Inheriting our Unit from Model (make sure that Model is visible in global scope by
  # using `global.Unit` instead of just `Unit`).
  class global.Unit extends Model
    # Specifying collection name this model will be saved to.
    @collection 'units'

    # There's no need to explicitly declare attributes, just use it as if it's a plain object.

  # Creating another Model, containing statistics about our Unit (it will be embedded into the
  # Unit).
  #
  # There are no difference between the Main and Embedded Models any Model can be used as a Main or
  # be Embedded in another.
  class global.Stats extends Model

  # ### CRUD

  # Let's create two great Heroes.
  zeratul  = new Unit name: 'Zeratul',  status: 'alive'
  zeratul.stats =  new Stats attack: 85, life: 300, shield: 100

  tassadar = new Unit name: 'Tassadar', status: 'dead'
  tassadar.stats = new Stats attack: 0,  life: 80,  shield: 300

  # Saving units to database.
  assert zeratul.save(), true
  assert tassadar.save(), true

  # We made an error - mistakenly set Tassadar's attack as zero, let's fix it.
  tassadar.stats.attack = 20
  assert tassadar.save(), true

  # ### Querying

  # All methods are (amost) the same as in MongoDB.
  assert Unit.first(name: 'Zeratul').name, 'Zeratul'
  list = Unit.all(name: 'Zeratul')
  assert (_(list).map (obj) -> obj.name), ['Zeratul']
  # There's also advanced `next` method, but we don't cover it in this sample.

  # Query helpers.
  assert Unit.limit(1).sort(name: 1).first().name, 'Tassadar'
  assert Unit.find(name: 'Zeratul').count(), 1

  # ### Other

  # Instead of default `BSON::ObjectId` id, Dirver generates
  # short and nice random string ids (can be disabled in config).
  assert Unit.first()._id.constructor, String

  # You also can convert model to Hash.
  assert Unit.first().toHash().name, 'Zeratul'

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered basics of [Model](model.html),
# please go to [contents](model.html) for more samples.