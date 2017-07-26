class App
  constructor: () ->
    @canvas = document.getElementById("canvas")
    @ctx = @canvas.getContext("2d")
    @switchButton = document.getElementById("switch")
    @refreshButton = document.getElementById("refresh")
    @unitNum = 30
    @unitSize = Math.floor(@canvas.height / @unitNum)
    @timerID = null
    @touchStart = []
    @directions = ["UP", "DOWN", "LEFT", "RIGHT"]
    @opposite =
      "UP": "DOWN"
      "DOWN": "UP"
      "LEFT": "RIGHT"
      "RIGHT": "LEFT"
    @refresh()
    addEventListener("keydown", @handleKeyDown, false)
    @canvas.addEventListener("touchstart", @handleTouchStart, false)
    @canvas.addEventListener("touchmove", @handleTouchMove, false)
    @canvas.addEventListener("touchend", @handleTouchEnd, false)
  createFood: () =>
    @food = [Math.floor(Math.random() * @unitNum), \
    Math.floor(Math.random() * @unitNum)]
    @checkPos(@food)
    while @isFoodInSnake()
      @food = [Math.floor(Math.random() * @unitNum), \
      Math.floor(Math.random() * @unitNum)]
      @checkPos(@Food)
  isFoodInSnake: () =>
    for body in @snake.list
      if @food[0] is body[0] and @food[1] is body[1]
        return true
    return false
  createSnake: () =>
    list = []
    headX = Math.floor(Math.random() * @unitNum)
    headY = Math.floor(Math.random() * @unitNum)
    move = @directions[Math.floor(Math.random() * @directions.length)]
    for i in [0...4]
      switch move
        when "UP"
          list.push([headX, headY + i])
        when "DOWN"
          list.push([headX, headY - i])
        when "LEFT"
          list.push([headX + i, headY])
        when "RIGHT"
          list.push([headX - i, headY])
    @snake.list = list
    @snake.move = move
  handleKeyDown: (event) =>
    switch event.keyCode
      when 38 then move = "UP"
      when 40 then move = "DOWN"
      when 37 then move = "LEFT"
      when 39 then move = "RIGHT"
      when 87 then move = "UP"
      when 83 then move = "DOWN"
      when 65 then move = "LEFT"
      when 68 then move = "RIGHT"
      when 32
        event.preventDefault()
        @switchButton.onclick()
      when 13
        event.preventDefault()
        @refreshButton.onclick()
    if move?
      event.preventDefault()
      @moveQueue.push(move)
  handleTouchStart: (event) =>
    if event.touches.length > 1 or event.targetTouches.length > 1
      return -1
    @touchStart = [event.touches[0].clientX, event.touches[0].clientY]
    event.preventDefault()
  handleTouchMove: (event) ->
    event.preventDefault()
  handleTouchEnd: (event) =>
    if event.touches.length or event.targetTouches.length > 0
      return -1
    dx = event.changedTouches[0].clientX - @touchStart[0]
    dy = event.changedTouches[0].clientY - @touchStart[1]
    absDx = Math.abs(dx)
    absDy = Math.abs(dy)
    @touchStart = []
    if Math.max(absDx, absDy) > 30
      move = (if absDx > absDy
        (if dx > 0 then "RIGHT" else "LEFT")
      else
        (if dy > 0 then "DOWN" else "UP"))
      event.preventDefault()
      @moveQueue.push(move)
  changeSnakeMove: () =>
    while @moveQueue.length and \
    (@snake.move is @opposite[@moveQueue[0]] or \
    @moveQueue[0] is @moveQueue[1])
      @moveQueue.shift()
    if @moveQueue.length
      @snake.move = @moveQueue.shift()
  insertSnakeHead: () =>
    headX = @snake.list[0][0]
    headY = @snake.list[0][1]
    switch @snake.move
      when "UP"
        @snake.list.unshift([headX, headY - 1])
      when "DOWN"
        @snake.list.unshift([headX, headY + 1])
      when "LEFT"
        @snake.list.unshift([headX - 1, headY])
      when "RIGHT"
        @snake.list.unshift([headX + 1, headY])
  deleteSnakeTail: () =>
    @snake.list.pop()
  moveSnake: () =>
    @changeSnakeMove()
    @insertSnakeHead()
    @checkAllPos()
    switch @checkHeadCollision()
      when 1 then @createFood()
      when 0 then @deleteSnakeTail()
      when -1
        @deleteSnakeTail()
        return -1
  checkPos: (point) =>
    point[0] %= @unitNum
    point[1] %= @unitNum
    while point[0] < 0 then point[0] += @unitNum
    while point[1] < 0 then point[1] += @unitNum
    return point
  checkAllPos: () =>
    @food = @checkPos(@food)
    @snake.list = (@checkPos(body) for body in @snake.list)
  checkHeadCollision: () =>
    for body in @snake.list[1...(@snake.list.length - 1)]
      if @snake.list[0][0] is body[0] and @snake.list[0][1] is body[1]
        return -1
    if @snake.list[0][0] is @food[0] and @snake.list[0][1] is @food[1]
      return 1
    return 0
  renderPresent: () =>
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @ctx.fillStyle = "rgba(0, 0, 200, 0.7)"
    @ctx.fillRect(@food[0] * @unitSize, @food[1] * @unitSize, \
    @unitSize, @unitSize)
    @ctx.fillStyle = "rgba(200, 0, 0, 0.7)"
    @ctx.fillRect(@snake.list[0][0] * @unitSize, \
    @snake.list[0][1] * @unitSize, @unitSize, @unitSize)
    for body in @snake.list[1...@snake.list.length]
      @ctx.fillStyle = "rgba(0, 0, 0, 0.7)"
      @ctx.fillRect(body[0] * @unitSize, body[1] * @unitSize, \
      @unitSize, @unitSize)
  main: () =>
    if @moveSnake() is -1 then @death()
    @renderPresent()
  start: () =>
    @timerID = setInterval(@main, 150)
    @switchButton.innerHTML = "暂停"
    @switchButton.onclick = @stop
  stop: () =>
    clearInterval(@timerID)
    @switchButton.innerHTML = "继续"
    @switchButton.onclick = @start
  death: () =>
    clearInterval(@timerID)
    @switchButton.innerHTML = "死啦"
    @switchButton.onclick = @refresh
  refresh: () =>
    if @timerID?
      clearInterval(@timerID)
    @moveQueue = []
    @food = []
    @snake = {}
    @createSnake()
    @createFood()
    @checkAllPos()
    @renderPresent()
    @switchButton.innerHTML = "开始"
    @switchButton.onclick = @start
    @refreshButton.innerHTML = "重来"
    @refreshButton.onclick = @refresh

app = new App()
