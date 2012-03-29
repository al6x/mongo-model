{exec} = require 'child_process'
execute = (cmd) ->
  # cmd = spawn cmd
  # cmd.stdout.on 'data', (data) -> process.stdout.write data
  # cmd.stderr.on 'data', (data) -> process.stderr.write data
  # cmd.on 'exit', (code) ->
  
  exec cmd, (err, stdout, stderr) ->
    return console.log err if err
    console.log stdout

task 'spec', 'Run Specs', ->
  #  --reporter spec
  execute 'find ./spec -name "*spec.coffee" | xargs mocha --compilers coffee:coffee-script'

task 'compile', 'Compile CoffeeScript to JavaScript', ->
  execute 'coffee --compile --output ./lib ./lib'

task 'clear', 'Clear compiled JavaScript', ->
  execute "find ./lib -name '*.js' | xargs rm -f"

# Docs.
task 'compile-docs', 'Compile CoffeeScript examples to JavaScript', ->
  execute 'coffee --compile --output ./examples ./examples'

task 'clear-docs', 'Clear JavaScript versions of examples', ->
  execute "find ./examples -name '*.js' | xargs rm -f"

task 'docs-spec', 'Run Specs for Documentation', ->
  execute 'find ./examples -name "*spec.coffee" | xargs mocha'

task 'generate-docs', 'Generate Documentation', ->
  execute 'docco examples/*.coffee'

task 'publish-docs', 'Publish Documentation', ->
  execute = (cmd, check, callback) ->
    console.log "executing #{cmd}"
    exec cmd, (err, stdout, stderr) ->
      throw err if err
      if check and !check.test(stdout + stderr)
        console.log stdout + stderr
        throw new Error "output of '#{cmd}' doesn't match #{check}"
      console.log stdout + stderr
      callback()

  execute "git status", /nothing to commit .working directory clean/, ->
    tmp = '~/tmp/publish-docs-tmp'
    execute "rm -rf #{tmp} && mkdir -p #{tmp}", null, ->
      execute "cp -r ./docs/* #{tmp}", null, ->
        execute "git checkout gh-pages", /Switched to branch 'gh-pages'/, ->
          execute "cp -r #{tmp}/* .", null, ->
            execute "git add .", null, ->
              execute "git commit -a -m 'upd docs'", /upd docs/, ->
                execute "git push", /gh-pages -> gh-pages/, ->
                  execute "git checkout master", /Switched to branch 'master'/, ->
                    console.log "Documentation published"