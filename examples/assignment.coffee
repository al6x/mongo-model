# Mass Assignment for [Model](model.html).
#
# In this example we'll discover how to define attribute types,
# and protect some of them from mass assignment.
Model = require 'mongo-model'
# Enabling optional [synchronous](synchronous.html) mode.
require 'mongo-model/lib/sync'
sync = ->

  # Connecting to default database and clearing it before starting.
  db = Model.db()
  db.clear()

  # Let's define User.
  class global.User extends Model

  # By defautl there's no any types and You can assign anything to
  # any attribute using the `set` method.
  user = new User()
  user.set name: 'Gordon Freeman', age: '28'
  assert [user.name, user.age], ['Gordon Freeman', '28']

  # In previous example the `age` attribute is supposed to be Number but
  # it has been assigned as a String.
  # This is wrong, we need to fix it.
  #
  # Note also that all such helpers also available in the following form:
  #
  #     class global.User extends Model
  #       @accessible 'age', Number
  #
  User.accessible 'age', Number
  User.accessible 'name'

  # If You need to set attributes from unsafe input with typecast You should
  # use `safeSet`.
  #
  # This time String will be casted to Number before assigning it to the `age` attribute.
  user.safeSet name: 'Gordon Freeman', age: '28'
  assert [user.name, user.age], ['Gordon Freeman', 28]

  # There are also sensitive attributes that shouldn't be allowed to
  # update in mass assignment. Let's add the `password` attribute and make it
  # protected.
  #
  # Actually there's no need to explicitly specify that attribute is protected,
  # if You don't make it `accessible` explicitly it will be protected by default.
  #
  # If we try to to change `password` using mass assignment it will not be updated.
  user.safeSet password: 'Black Mesa'
  assert user.password, undefined

  # You still can forcefully assign any attribute if You want.
  user.set password: 'Black Mesa'
  assert user.password, 'Black Mesa'

  # Closing connection.
  db.close()

# This stuff needed for [synchronous](synchronous.html) mode.
Fiber(sync).run()

global.assert = (args...) -> require('assert').deepEqual args...

# In this example we covered mass assignment, attribute types and attribute
# protection.