{exec} = require 'child_process'
execute = (cmd) ->
  exec cmd, (err, stdout, stderr) ->
    console.log err if err
    console.log stdout + stderr

task 'compile', 'Compile CoffeeScript to JavaScript', ->
  execute 'coffee --compile --output ./lib ./lib'

task 'clear', 'Clear compiled JavaScript', ->
  execute "find ./lib -name '*.js' | xargs rm -f"

task 'spec', 'Run Specs', ->
  execute 'jasmine-node --coffee spec'

task 'docs-spec', 'Run Specs for Documentation', ->
  execute 'jasmine-node --coffee examples'

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