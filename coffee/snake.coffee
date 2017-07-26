class App
  constructor: () ->
    @canvas = document.getElementById("canvas")
    @ctx = @canvas.getContext("2d")
    @switchButton = document.getElementById("switch")
    @refreshButton = document.getElementById("refresh")
    @unitNum = 30
    @unitSize = Math.floor(@canvas.height / @unitNum)
    @timerID = null
    @touch = []
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
  isFoodInSnake: () =>
    for body in @snake.list
      if @food[0] is body[0] and @food[1] is body[1]
        return true
    return false
  createSnake: () =>
    list = []
    head_x = Math.floor(Math.random() * @unitNum)
    head_y = Math.floor(Math.random() * @unitNum)
    for i in [0...4]
      list.push([head_x - i, head_y])
    move = "RIGHT"
    @snake.list = list
    @snake.move = move
  handleKeyDown: (event) =>
    switch event.keyCode
      when 38
        move = "UP"
      when 40
        move = "DOWN"
      when 37
        move = "LEFT"
      when 39
        move = "RIGHT"
      when 87
        move = "UP"
      when 83
        move = "DOWN"
      when 65
        move = "LEFT"
      when 68
        move = "RIGHT"
      when 32
        event.preventDefault()
        switch @switchButton.innerHTML
          when "死啦"
            @refresh()
          when "暂停"
            @stop()
          when "开始"
            @start()
          when "继续"
            @start()
      when 13
        event.preventDefault()
        @refresh()
    if move?
      event.preventDefault()
      @moveQueue.push(move)
  handleTouchStart: (event) =>
    if event.touches.length > 1 or event.targetTouches.length > 1
      return -1
    @touch.push([event.touches[0].clientX, event.touches[0].clientY])
    event.preventDefault()
  handleTouchMove: (event) ->
    event.preventDefault()
  handleTouchEnd: (event) =>
    if event.touches.length or event.targetTouches.length > 0
      return -1
    @touch.push([event.changedTouches[0].clientX, \
    event.changedTouches[0].clientY])
    dx = @touch[1][0] - @touch[0][0]
    dy = @touch[1][1] - @touch[0][1]
    absDx = Math.abs(dx)
    absDy = Math.abs(dy)
    @touch = []
    if Math.max(absDx, absDy) > 30
      if absDx > absDy
        if dx > 0
          move = "RIGHT"
        else
          move = "LEFT"
      else
        if dy > 0
          move = "DOWN"
        else
          move = "UP"
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
    head_x = @snake.list[0][0]
    head_y = @snake.list[0][1]
    switch @snake.move
      when "UP"
        @snake.list.unshift([head_x, head_y - 1])
      when "DOWN"
        @snake.list.unshift([head_x, head_y + 1])
      when "LEFT"
        @snake.list.unshift([head_x - 1, head_y])
      when "RIGHT"
        @snake.list.unshift([head_x + 1, head_y])
  deleteSnakeTail: () =>
    @snake.list.pop()
  moveSnake: () =>
    @changeSnakeMove()
    @insertSnakeHead()
    @checkAllPos()
    switch @checkHeadCollision()
      when 1
        @createFood()
        @checkAllPos()
        while @isFoodInSnake()
          @createFood()
          @checkAllPos()
      when 0
        @deleteSnakeTail()
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
    if @moveSnake() is -1
      @death()
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
    while @isFoodInSnake()
      @createFood()
      @checkAllPos()
    @renderPresent()
    @switchButton.innerHTML = "开始"
    @switchButton.onclick = @start
    @refreshButton.innerHTML = "重来"
    @refreshButton.onclick = @refresh

app = new App()
