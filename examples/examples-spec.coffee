# Spec for Documentation.

_ = require 'underscore'
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
    it "should execute '#{name}.coffee' without errors", (done) ->
      exec "coffee #{__dirname}/#{name}.coffee", (err, stdout, stderr) ->
        return done new Error "example #{name} is invalid!" if err or stderr != ""
        done()