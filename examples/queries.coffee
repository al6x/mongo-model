# Using Queries, Cursor and Scopes with [Model](model.html)
#
# In this example we'll see standard MongoDB Queries, Cursor and Scopes.
_     = require 'underscore'
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # Defining Game Unit.
  class global.Unit extends Model
    @collection 'units'

  # Populating database.
  zeratul  = Unit.create name: 'Zeratul',  race: 'Protoss', status: 'alive'
  tassadar = Unit.create name: 'Tassadar', race: 'Protoss', status: 'dead'
  jim      = Unit.create name: 'Jim',      race: 'Terran',  status: 'alive'

  # Simple queries.
  assert Unit.first(name: 'Zeratul').name, 'Zeratul'
  list = Unit.all(name: 'Zeratul')
  assert (_(list).map (obj) -> obj.name), ['Zeratul']

  # # Simple dynamic finders.
  # p Unit.by_name('Zeratul')                            # => Zeratul
  # p Unit.first_by_name('Zeratul')                      # => Zeratul
  # p Unit.all_by_name('Zeratul')                        # => [Zeratul]
  #
  # # Bang version, will raise error if nothing found.
  # p Unit.first!(name: 'Zeratul')                       # => Zeratul
  # p Unit.by_name!('Zeratul')                           # => Zeratul

  # Counting and checking for existence.
  assert Unit.count(), 3
  assert Unit.count(race: 'Protoss'), 2
  assert Unit.exists(name: 'Zeratul'), true
  assert zeratul.exists(), true

  # You can use Query Builder for complex queries, let's write
  # sample query with and without it.
  Unit.all {race: 'Protoss'}, sort: {name: -1}, limit: 1
  Unit.find(race: 'Protoss').sort(name: -1).limit(1).all()

  # Sometimes it's handy to define frequently used queries
  # on the model, such queries called Scopes.
  # Defining Game Unit.
  class global.Unit extends Model
    @collection 'units'

    # Specifying `alive` scope to easilly select all alive units.
    @alive: -> @find status: 'alive'

  # Now we can use Scope in queries.
  assert Unit.alive().count(), 2
  assert Unit.alive().find(name: 'Zeratul').first().name, 'Zeratul'

  # Pagination.
  perPage = 2
  list = Unit.paginate(1, perPage).sort(name: 1).all()
  assert (_(list).map (obj) -> obj.name), ['Jim', 'Tassadar']
  list = Unit.paginate(2, perPage).sort(name: 1).all()
  assert (_(list).map (obj) -> obj.name), ['Zeratul']

  # Model is tightly integrated with [Driver](driver.html),
  # so You can also use its API for querying.
  units = db.collection 'units'
  assert units.first(name: 'Jim').name, 'Jim'
  assert units.first(name: 'Jim').constructor, Unit

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered how to use Queries, Cursor and Scopes.