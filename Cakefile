{exec} = require("child_process")

task("build", "Build project from src/*.coffee to lib/*.js.", () ->
  exec("coffee --compile --output lib/ src/", (err, stdout, stderr) ->
    if err then throw err
    console.log(stdout + stderr)
  )
)

task("watch", "Watch project from src/*.coffee to lib/*.js.", () ->
  exec("coffee --compile --watch --output lib/ src/", (err, stdout, stderr) ->
    if err
      throw err
    console.log(stdout + stderr)
  )
)

task("deploy", "Deploy pages branch and push master and pages branches.", () ->
  exec("""
  coffee --compile --output lib/ src/; \
  git add .; \
  git commit -m "Deployed."; \
  git push origin master; \
  git push coding master; \
  git checkout pages; \
  git checkout master lib/snake.js; \
  echo 'git checkout master lib/snake.js'; \
  mv lib/snake.js js/snake.js; \
  echo '2'; \
  rmdir lib; \
  echo '3'; \
  git add .; \
  echo '4'; \
  git commit -m "Deployed."; \
  echo '5'; \
  git push origin pages:gh-pages; \
  echo '6'; \
  git push coding pages:coding-pages; \
  echo '7'; \
  git checkout master
  """, (err, stdout, stderr) ->
    if err then throw err
    console.log(stdout + stderr)
  )
)
