class DomCreator
  constructor: (@parentId) ->
    @parent = document.getElementById(@parentId)

  createPara: (innerHTML, others...) =>
    para = document.createElement("p")
    para.innerHTML = innerHTML
    if others[0]? then para.id = others[0]
    if others[1]? then para.className = others[1]
    @parent.appendChild(para)
    return para

  createSpan: (id, others...) =>
    para = document.createElement("p")
    span = document.createElement("span")
    span.id = id
    if others[0]? then para.className = others[0]
    para.appendChild(span)
    @parent.appendChild(para)
    return span

  createCanvas: (width, height, others...) =>
    para = document.createElement("p")
    canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height
    if others[0]? then canvas.id = others[0]
    if others[1]? then canvas.className = others[1]
    para.appendChild(canvas)
    @parent.appendChild(para)
    return canvas

  createButton: (id, others...) =>
    button = document.createElement("button")
    button.id = id
    if others[0]? then button.innerHTML = others[0]
    @parent.appendChild(button)
    if others[1]? then button.className = others[1]
    return button

  createRadio: (name, value, labelHTML, id, others...) =>
    radio = document.createElement("input")
    radio.type = "radio"
    radio.name = name
    radio.value = value
    label = document.createElement("label")
    label.innerHTML = labelHTML
    label.htmlFor = id
    radio.id = id
    if others[0]? and others[0] then radio.checked = true
    if others[1]? then radio.className = others[1]
    @parent.appendChild(radio)
    @parent.appendChild(label)
    return radio

  createBreak: () =>
    br = document.createElement("br")
    @parent.appendChild(br)
    return br

  createStyle: (innerHTML) =>
    style = document.createElement("style")
    style.innerHTML = innerHTML
    @parent.appendChild(style)
    return style

class FakeStorage
  constructor: () ->
    data = {}

  setItem: (id, val) =>
    return @data[id] = String(val)

  getItem: (id) =>
    return if @data.hasOwnProperty(id) then @data[id] else undefined

  removeItem: (id) =>
    return delete @data[id]

  clear: () =>
    @data = {}

class App
  constructor: (DomCreator) ->
    @createDom(DomCreator)
    @unitNum = 30
    @unitSize = Math.floor(@canvas.height / @unitNum)
    @timerId = null
    @status = "REFRESHED"
    @touchStart = []
    @directions = ["UP", "DOWN", "LEFT", "RIGHT"]
    @opposite = {
      "UP": "DOWN"
      "DOWN": "UP"
      "LEFT": "RIGHT"
      "RIGHT": "LEFT"
    }
    @intervals = [200, 150, 100]
    @interval = @intervals[1]
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
    if window.navigator.msPointerEnabled
      # Internet Explorer 10 style
      @eventTouchStart = "MSPointerDown"
      @eventTouchMove = "MSPointerMove"
      @eventTouchEnd = "MSPointerUp"
    else
      @eventTouchStart = "touchstart"
      @eventTouchMove = "touchmove"
      @eventTouchEnd = "touchend"
    @refresh()
    addEventListener("keydown", @handleButtonKeyDown, false)

  createDom: (DomCreator) =>
    @domCreator = new DomCreator("snakeGame")
    @scoreBar = @domCreator.createSpan("score")
    @canvas = @domCreator.createCanvas(300, 300, "snakeCanvas")
    @ctx = @canvas.getContext("2d")
    @upButton = @domCreator.createButton("up", "上")
    @upButton.onclick = () => @handleMoveButton("UP")
    @domCreator.createBreak()
    @leftButton = @domCreator.createButton("left", "左")
    @leftButton.onclick = () => @handleMoveButton("LEFT")
    @rightButton = @domCreator.createButton("right", "右")
    @rightButton.onclick = () => @handleMoveButton("RIGHT")
    @domCreator.createBreak()
    @downButton = @domCreator.createButton("down", "下")
    @downButton.onclick = () => @handleMoveButton("DOWN")
    @domCreator.createBreak()
    @switchButton = @domCreator.createButton("switch")
    @refreshButton = @domCreator.createButton("refresh")
    @domCreator.createPara("选择速度")
    @speedRadio = [@domCreator.createRadio("speed", "low", "低", "speed0"),
    @domCreator.createRadio("speed", "mid", "中", "speed1", true),
    @domCreator.createRadio("speed", "high", "高", "speed2")]
    @speedRadio[0].onclick = () => @setSpeed(0)
    @speedRadio[1].onclick = () => @setSpeed(1)
    @speedRadio[2].onclick = () => @setSpeed(2)
    @domCreator.createPara("选择地图")
    @mapRadio = [@domCreator.createRadio("map", "map0", "无地图", "map0", true),
    @domCreator.createRadio("map", "map1", "地图一", "map1"),
    @domCreator.createRadio("map", "map2", "地图二", "map2")]
    @mapRadio[0].onclick = () => @setMap(0)
    @mapRadio[1].onclick = () => @setMap(1)
    @mapRadio[2].onclick = () => @setMap(2)
    @domCreator.createPara("空格暂停/开始，回车重来")
    @domCreator.createPara("WASD、方向键或划屏操纵")
    @domCreator.createStyle("""
    .snakeGame {
      font: 16px/1.8 "Noto Sans", "Noto Sans CJK", "Lato", \
      "Microsoft Jhenghei", "Hiragino Sans GB", "Microsoft YaHei", \
      arial, sans-serif;
      color: #333;
      text-shadow: 4px 4px 4px #aaa;
      text-align: center;
    }

    .snakeGame p {
      margin: 5px auto 5px auto;
    }

    .snakeGame button {
    	font-size: 30px;
    	margin: 5px 30px 5px 30px;
      color: #fff;
      background-color: #d9534f;
      border-color: #d43f3a;
      display: inline-block;
      padding: 10px 15px 10px 15px;
      font-size: 14px;
      font-weight: 400;
      line-height: 1.42857143;
      white-space: nowrap;
      vertical-align: middle;
      touch-action: manipulation;
      cursor: pointer;
      user-select: none;
      background-image: none;
      border: 1px solid transparent;
      border-radius: 4px;
    }

    .snakeGame button:hover {
      color: #fff;
      background-color: #c9302c;
      border-color: #ac2925;
    }

    .snakeGame label {
      margin: auto 5px auto 5px;
    }
    """)
    if not window.fakeStorage?
      window.fakeStorage = new FakeStorage()
    @storage = (
      if @checkLocalStorage() then window.localStorage else window.fakeStorage
    )

  checkLocalStorage: () ->
    try
      window.localStorage.setItem("test", 1)
      window.localStorage.removeItem("test")
      return true
    catch err
      return false

  setStorage: () =>
    snakeStorage = {
      "score": @score,
      "status": "STOPPED",
      "food": @food,
      "snake": @snake,
      "map": @getMap(),
      "speed": @getSpeed()
    }
    @storage.setItem("snakeStorage", JSON.stringify(snakeStorage))

  getStorage: () =>
    if (snakeStorage = @storage.getItem("snakeStorage"))?
      return JSON.parse(snakeStorage)
    else
      return undefined

  loadStorage: (snakeStorage) =>
    for mapRadio in @mapRadio
      mapRadio.checked = false
    @mapRadio[snakeStorage["map"]].checked = true
    @mapRadio[snakeStorage["map"]].onclick()
    for speedRadio in @speedRadio
      speedRadio.checked = false
    @speedRadio[snakeStorage["speed"]].checked = true
    @speedRadio[snakeStorage["speed"]].onclick()
    @score = snakeStorage["score"]
    @status = snakeStorage["status"]
    @food = snakeStorage["food"]
    @snake = snakeStorage["snake"]
    @setButtonContent()
    @setScore()
    @renderPresent()

  removeStorage: () =>
    @storage.removeItem("snakeStorage")

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
        @addScore(1)
        @createFood()
        return 1
      # Nothing, just move forward by removing a tail.
      when 0
        @deleteSnakeTail()
        return 0
      # Death.
      when -1
        @deleteSnakeTail()
        return -1

  addScore: (num) =>
    @score += num
    @setScore()

  setScore: () =>
    @scoreBar.innerHTML = "#{@score} 分"

  clearScore: () =>
    @score = 0
    @setScore()

  drawBackground: () =>
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    for i in [0...@unitNum]
      for j in [0...@unitNum]
        if (i + j) % 2
          @ctx.fillStyle = "rgba(200, 200, 200, 0.5)"
        else
          @ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
        @ctx.fillRect(i * @unitSize, j * @unitSize, @unitSize, @unitSize)

  drawWall: () =>
    for brick in @map.wall
      @ctx.fillStyle = "rgba(3, 3, 3, 0.7)"
      @ctx.fillRect(brick[0] * @unitSize, brick[1] * @unitSize, \
      @unitSize, @unitSize)

  drawFood: () =>
    @ctx.strokeStyle = "rgba(0, 100, 100, 1)"
    @ctx.strokeRect(@food[0] * @unitSize, @food[1] * @unitSize, \
    @unitSize, @unitSize)

  drawSnake: () =>
    for body in @snake.list[1...@snake.list.length]
      @ctx.fillStyle = "rgba(100, 100, 200, 1)"
      @ctx.fillRect(body[0] * @unitSize, body[1] * @unitSize, \
      @unitSize, @unitSize)
    @ctx.fillStyle = "rgba(200, 0, 0, 1)"
    @ctx.fillRect(@snake.list[0][0] * @unitSize, \
    @snake.list[0][1] * @unitSize, @unitSize, @unitSize)

  drawBorder: () =>
    @ctx.strokeStyle = "rgba(3, 3, 3, 0.7)"
    @ctx.strokeRect(0, 0, @canvas.width, @canvas.height)

  renderPresent: () =>
    @drawBackground()
    @drawWall()
    @drawFood()
    @drawSnake()
    @drawBorder()

  handleMoveButton: (move) =>
    if move.toUpperCase() in @directions
      @moveQueue.push(move.toUpperCase())

  handleButtonKeyDown: (event) =>
    switch event.keyCode
      # Space.
      when 32
        event.preventDefault()
        @switchButton.onclick()
      # Enter.
      when 13
        event.preventDefault()
        @refreshButton.onclick()

  handleMoveKeyDown: (event) =>
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
    if move?
      event.preventDefault()
      @moveQueue.push(move)

  handleTouchStart: (event) =>
    # Only handle one finger touch.
    if event.touches.length > 1 or event.targetTouches.length > 1
      return -1
    if window.navigator.msPointerEnabled
      @touchStart = [event.pageX, event.pageY]
    else
      @touchStart = [event.touches[0].clientX, event.touches[0].clientY]
    event.preventDefault()

  handleTouchMove: (event) ->
    event.preventDefault()

  handleTouchEnd: (event) =>
    # Only handle one finger touch.
    if event.touches.length > 0 or event.targetTouches.length > 0
      return -1
    if window.navigator.msPointerEnabled
      dx = event.pageX - @touchStart[0]
      dy = event.pageY - @touchStart[1]
    else
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

  setSpeed: (level) =>
    if level in [0...@intervals.length]
      @interal = @intervals[level]
      @removeStorage()
      @refresh()
    else
      # Default speed.
      @interal = @intervals[1]
      @removeStorage()
      @refresh()

  getSpeed: () =>
    if @speedRadio[0].checked
      return 0
    else if @speedRadio[2].checked
      return 2
    else
      return 1

  setMap: (level) =>
    if level in [0...@maps.length]
      @map = @maps[level]
      @removeStorage()
      @refresh()
    else
      # Default map.
      @map = @maps[0]
      @removeStorage()
      @refresh()

  getMap: () =>
    if @mapRadio[1].checked
      return 1
    else if @mapRadio[2].checked
      return 2
    else
      return 0

  setButtonContent: () =>
    switch @status
      when "STARTED"
        @switchButton.innerHTML = "暂停"
        @switchButton.onclick = @stop
      when "STOPPED"
        @switchButton.innerHTML = "继续"
        @switchButton.onclick = @start
      when "DEAD"
        @switchButton.innerHTML = "死啦"
        @switchButton.onclick = () =>
          @removeStorage()
          @refresh()
      when "REFRESHED"
        @switchButton.innerHTML = "开始"
        @switchButton.onclick = @start
        @refreshButton.innerHTML = "重来"
        @refreshButton.onclick = () =>
          @removeStorage()
          @refresh()

  main: () =>
    result = @moveSnake()
    @setStorage()
    @renderPresent()
    if result is -1 then @death()

  start: () =>
    addEventListener("keydown", @handleMoveKeyDown, false)
    @canvas.addEventListener(@eventTouchStart, @handleTouchStart, false)
    @canvas.addEventListener(@eventTouchMove, @handleTouchMove, false)
    @canvas.addEventListener(@eventTouchEnd, @handleTouchEnd, false)
    @timerId = setInterval(@main, @interval)
    @status = "STARTED"
    @setButtonContent()

  stop: () =>
    removeEventListener("keydown", @handleMoveKeyDown, false)
    @canvas.removeEventListener(@eventTouchStart, @handleTouchStart, false)
    @canvas.removeEventListener(@eventTouchMove, @handleTouchMove, false)
    @canvas.removeEventListener(@eventTouchEnd, @handleTouchEnd, false)
    clearInterval(@timerId)
    @timerId = null
    @status = "STOPPED"
    @setButtonContent()

  death: () =>
    removeEventListener("keydown", @handleMoveKeyDown, false)
    @canvas.removeEventListener("touchstart", @handleTouchStart, false)
    @canvas.removeEventListener("touchmove", @handleTouchMove, false)
    @canvas.removeEventListener("touchend", @handleTouchEnd, false)
    clearInterval(@timerId)
    @removeStorage()
    @timerId = null
    @status = "DEAD"
    @setButtonContent()
    img = new Image()
    topBase = 10
    img.onload = () =>
      # QRCode.
      @ctx.drawImage(img, Math.floor((@canvas.width - img.width) / 2), \
      topBase + 30 + 10 + 30 + 10, 200, 200)
    img.src = "images/snake_qrcode.png"
    @ctx.fillStyle = "rgba(255, 255, 255, 0.3)"
    @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
    @ctx.fillStyle = "rgba(3, 3, 3, 0.7)"
    @ctx.font = "30px sans"
    @ctx.textAlign = "start"
    @ctx.textBaseline = "top"
    str = "你获得了 #{@score} 分"
    text = @ctx.measureText(str)
    @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2), topBase)
    str = "截图分享给朋友吧"
    text = @ctx.measureText(str)
    @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2), \
    topBase + 30 + 10)
    # Text shadow.
    @ctx.fillStyle = "rgba(10, 10, 10, 0.5)"
    str = "你获得了 #{@score} 分"
    text = @ctx.measureText(str)
    @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2) + 2, \
    topBase + 2)
    str = "截图分享给朋友吧"
    text = @ctx.measureText(str)
    @ctx.fillText(str, Math.floor((@canvas.width - text.width) / 2) + 2, \
    topBase + 30 + 10 + 2)

  refresh: () =>
    if @timerId?
      clearInterval(@timerId)
    @moveQueue = []
    @food = []
    @snake = {}
    @clearScore()
    @createSnake()
    @createFood()
    @renderPresent()
    @status = "REFRESHED"
    @setButtonContent()
    if (snakeStorage = @getStorage())?
      @loadStorage(snakeStorage)
    else
      @setStorage()

app = new App(DomCreator)
