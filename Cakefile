{exec} = require 'child_process'
execute = (cmd) ->
  exec cmd, (err, stdout, stderr) ->
    console.log err if err
    console.log stdout + stderr

task 'compile', 'Compile CoffeeScript to JavaScript', ->
  execute 'coffee --compile --output ./lib ./lib'

task 'docs', 'Generate Documentation', ->
  execute 'docco examples/*.coffee'

task 'docs-spec', 'Run Specs for Documentation', ->
  execute 'jasmine-node --coffee examples'

task 'spec', 'Run Specs', ->
  execute 'jasmine-node --coffee spec'