{exec} = require("child_process")

task("build", "Build project from src/*.coffee to lib/*.js.", () ->
  exec("coffee --compile --output lib/ src/", (err, stdout, stderr) ->
    if err
      throw err
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

task("deploy", "Deploy pages in pages branch to GitHub and Coding.", () ->
	exec("""
  coffee --compile --output lib/ src/ && \
  ))
