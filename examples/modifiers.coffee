# Usually if You want to update [Model](model.html) You load it, make changes
# and save it back. But if You want to update only some of attributes
# there's more efficient way - modifiers.
#
# In this example we'll create simple Model and update it using modifiers.
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # Defining game Unit.
  class global.Unit extends Model
    @collection 'units'

  # Creating brave Tassadar.
  tassadar = Unit.create name: 'Tassadar', life: 80

  # Updating Model with modifiers.
  tassadar.update $inc: {life: -40}
  tassadar.reload()
  assert tassadar.life, 40

  # There's also helper on the model class.
  Unit.update {id: tassadar.id}, {$inc: {life: -20}}
  tassadar.reload()
  assert tassadar.life, 20

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered using modifiers with Model.