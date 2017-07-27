class App
  constructor: () ->
    @canvas = document.getElementById("snakeCanvas")
    @ctx = @canvas.getContext("2d")
    @scoreBar = document.getElementById("score")
    @switchButton = document.getElementById("switch")
    @refreshButton = document.getElementById("refresh")
    @speedRadio = [document.getElementById("speed0"), \
    document.getElementById("speed1"), \
    document.getElementById("speed2")]
    @mapRadio = [document.getElementById("map0"), \
    document.getElementById("map1"), \
    document.getElementById("map2")]
    @speedRadio[0].onclick = @setSpeed
    @speedRadio[1].onclick = @setSpeed
    @speedRadio[2].onclick = @setSpeed
    @mapRadio[0].onclick = @setMap
    @mapRadio[1].onclick = @setMap
    @mapRadio[2].onclick = @setMap
    @unitNum = 30
    @unitSize = Math.floor(@canvas.height / @unitNum)
    @timerId = null
    @touchStart = []
    @directions = ["UP", "DOWN", "LEFT", "RIGHT"]
    @opposite = {
      "UP": "DOWN"
      "DOWN": "UP"
      "LEFT": "RIGHT"
      "RIGHT": "LEFT"
    }
    @interval = 150
    @maps = [
      {
        "head": null
        "move": null
        "wall": []
      },
      {
        "head": [14, 14]
        "move": "RIGHT"
        "wall": [
          [0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], \
          [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], \
          [23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0], [29, 0], \
          [29, 1], [29, 2], [29, 3], [29, 4], [29, 5], [29, 6], \
          [0, 29], [1, 29], [2, 29], [3, 29], [4, 29], [5, 29], [6, 29], \
          [0, 23], [0, 24], [0, 25], [0, 26], [0, 27], [0, 28], \
          [23, 29], [24, 29], [25, 29], [26, 29], [27, 29], [28, 29], \
          [29, 29], [29, 23], [29, 24], [29, 25], [29, 26], [29, 27], \
          [29, 28], \
          [10, 10], [11, 10], [12, 10], [13, 10], [14, 10], [15, 10], \
          [16, 10], [17, 10], [18, 10], [19, 10], \
          [10, 19], [11, 19], [12, 19], [13, 19], [14, 19], [15, 19], \
          [16, 19], [17, 19], [18, 19], [19, 19]
        ]
      },
      {
        "head": [10, 13],
        "move": "RIGHT",
        "wall": [
          [23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0], [29, 0], \
          [29, 10], [29, 11], [29, 12], [29, 13], [29, 14], \
          [15, 0], [15, 1], [15, 2], [15, 3], [15, 4], [15, 5], [15, 6], \
          [15, 7], [15, 8], [15, 9], [0, 10], [1, 10], [2, 10], [3, 10], \
          [4, 10], [5, 10], [6, 10], [7, 10], [8, 10], [9, 10], [10, 10], \
          [11, 10], [12, 10], [13, 10], [14, 10], [15, 10], [0, 20], \
          [1, 20], [2, 20], [3, 20], [4, 20], [5, 20], [6, 20], [7, 20], \
          [8, 20], [9, 20], [10, 20], [11, 20], [12, 20], [13, 20], \
          [14, 20], [15, 20], [16, 20], [17, 20], [18, 20], [19, 20], \
          [20, 20], [21, 20], [22, 20], [23, 20], [24, 20], [25, 20], \
          [26, 20], [27, 20], [28, 20], [29, 20]
        ]
      }
    ]
    @map = @maps[0]
    @refresh()
    addEventListener("keydown", @handleKeyDown, false)
    @canvas.addEventListener("touchstart", @handleTouchStart, false)
    @canvas.addEventListener("touchmove", @handleTouchMove, false)
    @canvas.addEventListener("touchend", @handleTouchEnd, false)
  fixPos: (point) =>
    # Limit point's position in 0 to unit number.
    point[0] %= @unitNum
    point[1] %= @unitNum
    while point[0] < 0 then point[0] += @unitNum
    while point[1] < 0 then point[1] += @unitNum
    return point
  createSnake: () =>
    list = []
    if @map.head?
      # Map has snake spawn point.
      headX = @map.head[0]
      headY = @map.head[1]
    else
      # Map has no snake spawn point, use random point.
      headX = Math.floor(Math.random() * @unitNum)
      headY = Math.floor(Math.random() * @unitNum)
    if @map.move?
      # Map has initial move direction.
      move = @map.move
    else
      # Map has no initial move direction, use random direcction.
      move = @directions[Math.floor(Math.random() * @directions.length)]
    # Set initial 4 body of snake.
    for i in [0...4]
      switch move
        when "UP"
          list.push(@fixPos([headX, headY + i]))
        when "DOWN"
          list.push(@fixPos([headX, headY - i]))
        when "LEFT"
          list.push(@fixPos([headX + i, headY]))
        when "RIGHT"
          list.push(@fixPos([headX - i, headY]))
    @snake.list = list
    @snake.move = move
  createFood: () =>
    # Set random food.
    @food = [Math.floor(Math.random() * @unitNum), \
    Math.floor(Math.random() * @unitNum)]
    # If food in snake or wall, then recreate.
    while @checkFoodCollision()
      @food = [Math.floor(Math.random() * @unitNum), \
      Math.floor(Math.random() * @unitNum)]
  checkFoodCollision: () =>
    # Check whether food in other entities' place.
    for body in @snake.list
      if @food[0] is body[0] and @food[1] is body[1]
        return true
    for brick in @map.wall
      if @food[0] is brick[0] and @food[1] is brick[1]
        return true
    return false
  changeSnakeMove: () =>
    # If moveQueue has repeated directions, or has opposite directions in
    # the head (snake cannot move back), remove all of those directions.
    while @moveQueue.length and \
    (@snake.move is @opposite[@moveQueue[0]] or \
    @moveQueue[0] is @moveQueue[1] or \
    @snake.move is @moveQueue[0])
      @moveQueue.shift()
    # Change direction once.
    if @moveQueue.length
      @snake.move = @moveQueue.shift()
  insertSnakeHead: () =>
    # To move a snake, first insert a head.
    # Then you may remove the tail, and it looks like moving.
    headX = @snake.list[0][0]
    headY = @snake.list[0][1]
    switch @snake.move
      when "UP"
        @snake.list.unshift(@fixPos([headX, headY - 1]))
      when "DOWN"
        @snake.list.unshift(@fixPos([headX, headY + 1]))
      when "LEFT"
        @snake.list.unshift(@fixPos([headX - 1, headY]))
      when "RIGHT"
        @snake.list.unshift(@fixPos([headX + 1, headY]))
  checkHeadCollision: () =>
    # Check whether head eat food or knock something.
    for body in @snake.list[1...(@snake.list.length - 1)]
      if @snake.list[0][0] is body[0] and @snake.list[0][1] is body[1]
        return -1
    for brick in @map.wall
      if @snake.list[0][0] is brick[0] and @snake.list[0][1] is brick[1]
        return -1
    if @snake.list[0][0] is @food[0] and @snake.list[0][1] is @food[1]
      return 1
    return 0
  deleteSnakeTail: () =>
    @snake.list.pop()
  moveSnake: () =>
    @changeSnakeMove()
    @insertSnakeHead()
    switch @checkHeadCollision()
      # Food ate, create new food.
      when 1
        @score++
        @scoreBar.innerHTML = "#{@score} 分"
        @createFood()
      # Nothing, just move forward by removing a tail.
      when 0 then @deleteSnakeTail()
      # Death.
      when -1
        @deleteSnakeTail()
        return -1
  renderPresent: () =>
    # Draw background.
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    for i in [0...@unitNum]
      for j in [0...@unitNum]
        if (i + j) % 2
          @ctx.fillStyle = "rgba(200, 200, 200, 0.5)"
        else
          @ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
        @ctx.fillRect(i * @unitSize, j * @unitSize, @unitSize, @unitSize)
    # Draw wall.
    for brick in @map.wall
      @ctx.fillStyle = "rgba(0, 0, 0, 0.7)"
      @ctx.fillRect(brick[0] * @unitSize, brick[1] * @unitSize, \
      @unitSize, @unitSize)
    # Draw food.
    @ctx.strokeStyle = "rgba(0, 100, 100, 1)"
    @ctx.strokeRect(@food[0] * @unitSize, @food[1] * @unitSize, \
    @unitSize, @unitSize)
    # Draw body.
    for body in @snake.list[1...@snake.list.length]
      @ctx.fillStyle = "rgba(100, 100, 200, 1)"
      @ctx.fillRect(body[0] * @unitSize, body[1] * @unitSize, \
      @unitSize, @unitSize)
    # Draw head.
    @ctx.fillStyle = "rgba(200, 0, 0, 1)"
    @ctx.fillRect(@snake.list[0][0] * @unitSize, \
    @snake.list[0][1] * @unitSize, @unitSize, @unitSize)
    # Draw border.
    @ctx.strokeStyle = "rgba(0, 0, 0, 1)"
    @ctx.strokeRect(0, 0, @canvas.width, @canvas.height)
  handleKeyDown: (event) =>
    switch event.keyCode
      # Up arrow.
      when 38 then move = "UP"
      # Down arrow.
      when 40 then move = "DOWN"
      # Left arrow.
      when 37 then move = "LEFT"
      # Right arrow.
      when 39 then move = "RIGHT"
      # W.
      when 87 then move = "UP"
      # S.
      when 83 then move = "DOWN"
      # A.
      when 65 then move = "LEFT"
      # D.
      when 68 then move = "RIGHT"
      # Space.
      when 32
        event.preventDefault()
        @switchButton.onclick()
      # Enter.
      when 13
        event.preventDefault()
        @refreshButton.onclick()
    if move?
      event.preventDefault()
      @moveQueue.push(move)
  handleTouchStart: (event) =>
    # Only handle one finger touch.
    if event.touches.length > 1 or event.targetTouches.length > 1
      return -1
    @touchStart = [event.touches[0].clientX, event.touches[0].clientY]
    event.preventDefault()
  handleTouchMove: (event) ->
    event.preventDefault()
  handleTouchEnd: (event) =>
    # Only handle one finger touch.
    if event.touches.length > 0 or event.targetTouches.length > 0
      return -1
    dx = event.changedTouches[0].clientX - @touchStart[0]
    dy = event.changedTouches[0].clientY - @touchStart[1]
    absDx = Math.abs(dx)
    absDy = Math.abs(dy)
    @touchStart = []
    # Only handle when move distance is bigger than 30.
    if Math.max(absDx, absDy) > 30
      move = (if absDx > absDy
        (if dx > 0 then "RIGHT" else "LEFT")
      else
        (if dy > 0 then "DOWN" else "UP"))
      event.preventDefault()
      @moveQueue.push(move)
  setSpeed: () =>
    if @speedRadio[0].checked
      @interval = 200
      @refresh()
    else if @speedRadio[2].checked
      @interval = 100
      @refresh()
    else
      @interval = 150
      @refresh()
  setMap: () =>
    if @mapRadio[1].checked
      @map = @maps[1]
      @refresh()
    else if @mapRadio[2].checked
      @map = @maps[2]
      @refresh()
    else
      @map = @maps[0]
      @refresh()
  main: () =>
    result = @moveSnake()
    @renderPresent()
    if result is -1 then @death()
  start: () =>
    @timerId = setInterval(@main, @interval)
    @switchButton.innerHTML = "暂停"
    @switchButton.onclick = @stop
  stop: () =>
    clearInterval(@timerId)
    @switchButton.innerHTML = "继续"
    @switchButton.onclick = @start
  death: () =>
    clearInterval(@timerId)
    @switchButton.innerHTML = "死啦"
    @switchButton.onclick = @refresh
    img = new Image()
    img.src = "images/qrcode_transparent.png"
    img.onload = () =>
      @ctx.fillStyle = "rgba(255, 255, 255, 0.3)"
      @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
      @ctx.fillStyle = "rgba(0, 0, 0, 0.7)"
      @ctx.font = "30px sans"
      @ctx.textAlign = "start"
      @ctx.textBaseline = "top"
      topBase = 10
      str = "你获得了 #{@score} 分"
      text = @ctx.measureText(str)
      @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2), topBase)
      str = "截图分享给朋友吧"
      text = @ctx.measureText(str)
      @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2), \
      topBase + 30 + 10)
      # Text shadow.
      @ctx.fillStyle = "rgba(0, 0, 0, 0.5)"
      str = "你获得了 #{@score} 分"
      text = @ctx.measureText(str)
      @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2) + 2, \
      topBase + 2)
      str = "截图分享给朋友吧"
      text = @ctx.measureText(str)
      @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2) + 2, \
      topBase + 30 + 10 + 2)
      # QRCode.
      @ctx.drawImage(img, Math.floor((@canvas.width - img.width) / 2), \
      topBase + 30 + 10 + 30 + 10)
  refresh: () =>
    if @timerId?
      clearInterval(@timerId)
    @moveQueue = []
    @food = []
    @snake = {}
    @score = 0
    @scoreBar.innerHTML = "#{@score} 分"
    @createSnake()
    @createFood()
    @renderPresent()
    @switchButton.innerHTML = "开始"
    @switchButton.onclick = @start
    @refreshButton.innerHTML = "重来"
    @refreshButton.onclick = @refresh

app = new App()
