# Spec for Documentation.

_ = require 'underscore'
require 'mary'
{exec} = require 'child_process'

examples = [
  'assignment'
  'associations'
  'basics'
  'callbacks'
  'embedded'
  'database'
  'driver'
  # 'model'
  'modifiers'
  'queries'
  'synchronous'
  'validations'
]

describe "Examples", ->
  _(examples).each (name) ->
    it.async "should execute '#{name}.coffee' without errors", ->
      exec "coffee #{__dirname}/#{name}.coffee", (err, stdout, stderr) ->
        if err or stderr != ""
          throw new Error "example #{name} is invalid!"
        it.next()