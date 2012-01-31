# [Model](model.html) supports two modes - asynchronous and synchronous.
#
# - Asynchronous mode - it's just usual Node.JS mode, with plain JavaScript and Callbacks.
# - Synchronous mode is optional and experimental it also depends on the `fibers` library.
#
# In this example we'll discower why You may need synchronous mode and how to use it.
#
# *This is optional topic, if You prefer to use plain JavaScript callbacks - You can safely
# ignore this example.*
#
# ### A little of Theory
#
# As You probably know Node.JS is asynchronous and never-blocking, and this is good.
# The bad is that asynchronous code is more complicated than synchronous (even
# with async control flow helpers).
#
# But it seems that in some cases it's possible to get the best from both worlds - make
# code looks like synchronous but behave as asynchronous never-blocking.
# And this is what synchronous mode tries to do.
#
# Thankfully it was relativelly easy to implement, thanks to the
# exellent [fibers](https://github.com/laverdet/node-fibers) library.
#
# ### Enabling synchronous mode.
#
# As I said before sync mode is optional and You need to install `fibers` manually `npm install fibers`.

# Requiring Model.
Model = require 'mongo-model'

# You also need to switch to synchronous mode.
require 'mongo-model/lib/sync'

# Just a handy helper.
global.assert = (args...) -> require('assert').deepEqual args...

# And wrap Your code inside of Fiber.
Fiber(->
  db = Model.db()
  db.clear()
  units = db.collection 'units'
  units.save name: 'Zeratul'
  assert units.first(name: 'Zeratul').name, 'Zeratul'
  db.close()
).run()

# After enabling sync mode You still can use it in async way, let's rewrite code above.
Model.db (err, db) ->
  return throw err if err
  db.clear (err) ->
    return throw err if err
    db.collection 'units', (err, units) ->
      return throw err if err
      units.save name: 'Zeratul', (err, result) ->
        return throw err if err
        units.first name: 'Zeratul', (err, unit) ->
          return throw err if err
          assert unit.name, 'Zeratul'
          db.close()

# You can also mix sync and async code simultaneously.
Fiber(->
  db = Model.db()
  db.clear()
  db.collection 'units', (err, units) ->
    units.save name: 'Zeratul'
    assert units.first(name: 'Zeratul').name, 'Zeratul'
    db.close()
).run()

# All methods (well, almost all) of [Driver](driver.html) and [Model](model.html) support both sync and async style.
# It's also very handy to use sync style for writing specs, take a look at the `spec/helper.coffe` to see how it works.

# In this sample we covered how to use synchronous mode with [Driver](driver.html) and [Model](model.html).