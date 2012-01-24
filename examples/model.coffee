# Domain Model for MongoDB (Node.JS).
#
# - Models are (almost) pure JavaScript Objects.
# - Minimum extra abstractions, trying to keep things as close to the semantic of MongoDB as possible.
# - [Schema-less, dynamic](basics.html) (with ability to specify types for [mass-assignment](assignment.html)).
# - Models can be saved to [any collection](database.html), dynamically.
# - Full support for [composite / embedded objects](composite.html) (with [validations](validations.html),
# [callbacks](callbacks.html), ...).
# - [Scopes](queries.html) and handy helpers for [querying](queries.html).
# - [Multiple](database.html) simultaneous connections and databases.
# - [Associations](associations.html).
# - Same API for [Driver](driver.html) and Model.
# - Optional support for [synchronous](synchronous.html) mode (with Fibers).
# - Small codebase.
#
# Short [presentation](presentations/introduction/index.html).
#
# ### Installation
#
#     npm install mongo-model
#
# ### Examples
#
# [Basics](basics.html), [Composite and Embedded Models](composite.html), [Queries and Scopes](queries.html),
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
# So, You need to install Fibers & CoffeeScript to run examples:
#
#     npm install coffee-script fibers
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