// Generated by CoffeeScript 1.12.6
(function() {
  var App, DomCreator, app,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    slice = [].slice;

  DomCreator = (function() {
    function DomCreator(parentId) {
      this.parentId = parentId;
      this.createRadio = bind(this.createRadio, this);
      this.createButton = bind(this.createButton, this);
      this.createCanvas = bind(this.createCanvas, this);
      this.createSpan = bind(this.createSpan, this);
      this.createPara = bind(this.createPara, this);
      this.parent = document.getElementById(this.parentId);
    }

    DomCreator.prototype.createPara = function() {
      var innerHTML, others, para;
      innerHTML = arguments[0], others = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      para = document.createElement("p");
      para.innerHTML = innerHTML;
      if (others[0] != null) {
        para.id = others[0];
      }
      this.parent.appendChild(para);
      return para;
    };

    DomCreator.prototype.createSpan = function(id) {
      var para, span;
      para = document.createElement("p");
      span = document.createElement("span");
      span.id = id;
      para.appendChild(span);
      this.parent.appendChild(para);
      return span;
    };

    DomCreator.prototype.createCanvas = function() {
      var canvas, height, others, para, width;
      width = arguments[0], height = arguments[1], others = 3 <= arguments.length ? slice.call(arguments, 2) : [];
      para = document.createElement("p");
      canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;
      if (others[0] != null) {
        canvas.id = others[0];
      }
      para.appendChild(canvas);
      this.parent.appendChild(para);
      return canvas;
    };

    DomCreator.prototype.createButton = function() {
      var button, id, others;
      id = arguments[0], others = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      button = document.createElement("button");
      button.id = id;
      if (others[0] != null) {
        button.className = others[0];
      }
      this.parent.appendChild(button);
      return button;
    };

    DomCreator.prototype.createRadio = function() {
      var id, label, labelHTML, name, others, radio, value;
      name = arguments[0], value = arguments[1], labelHTML = arguments[2], id = arguments[3], others = 5 <= arguments.length ? slice.call(arguments, 4) : [];
      radio = document.createElement("input");
      radio.type = "radio";
      radio.name = name;
      radio.value = value;
      label = document.createElement("label");
      label.innerHTML = labelHTML;
      label.htmlFor = id;
      radio.id = id;
      if ((others[0] != null) && others[0]) {
        radio.checked = true;
      }
      this.parent.appendChild(radio);
      this.parent.appendChild(label);
      return radio;
    };

    return DomCreator;

  })();

  App = (function() {
    function App(DomCreator) {
      this.refresh = bind(this.refresh, this);
      this.death = bind(this.death, this);
      this.stop = bind(this.stop, this);
      this.start = bind(this.start, this);
      this.main = bind(this.main, this);
      this.setMap = bind(this.setMap, this);
      this.setSpeed = bind(this.setSpeed, this);
      this.handleTouchEnd = bind(this.handleTouchEnd, this);
      this.handleTouchStart = bind(this.handleTouchStart, this);
      this.handleMoveKeyDown = bind(this.handleMoveKeyDown, this);
      this.handleButtonKeyDown = bind(this.handleButtonKeyDown, this);
      this.renderPresent = bind(this.renderPresent, this);
      this.moveSnake = bind(this.moveSnake, this);
      this.deleteSnakeTail = bind(this.deleteSnakeTail, this);
      this.checkHeadCollision = bind(this.checkHeadCollision, this);
      this.insertSnakeHead = bind(this.insertSnakeHead, this);
      this.changeSnakeMove = bind(this.changeSnakeMove, this);
      this.checkFoodCollision = bind(this.checkFoodCollision, this);
      this.createFood = bind(this.createFood, this);
      this.createSnake = bind(this.createSnake, this);
      this.fixPos = bind(this.fixPos, this);
      this.createDom = bind(this.createDom, this);
      this.createDom(DomCreator);
      this.unitNum = 30;
      this.unitSize = Math.floor(this.canvas.height / this.unitNum);
      this.timerId = null;
      this.touchStart = [];
      this.directions = ["UP", "DOWN", "LEFT", "RIGHT"];
      this.opposite = {
        "UP": "DOWN",
        "DOWN": "UP",
        "LEFT": "RIGHT",
        "RIGHT": "LEFT"
      };
      this.interval = 150;
      this.maps = [
        {
          "head": null,
          "move": null,
          "wall": []
        }, {
          "head": [14, 14],
          "move": "RIGHT",
          "wall": [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0], [29, 0], [29, 1], [29, 2], [29, 3], [29, 4], [29, 5], [29, 6], [0, 29], [1, 29], [2, 29], [3, 29], [4, 29], [5, 29], [6, 29], [0, 23], [0, 24], [0, 25], [0, 26], [0, 27], [0, 28], [23, 29], [24, 29], [25, 29], [26, 29], [27, 29], [28, 29], [29, 29], [29, 23], [29, 24], [29, 25], [29, 26], [29, 27], [29, 28], [10, 10], [11, 10], [12, 10], [13, 10], [14, 10], [15, 10], [16, 10], [17, 10], [18, 10], [19, 10], [10, 19], [11, 19], [12, 19], [13, 19], [14, 19], [15, 19], [16, 19], [17, 19], [18, 19], [19, 19]]
        }, {
          "head": [10, 13],
          "move": "RIGHT",
          "wall": [[23, 0], [24, 0], [25, 0], [26, 0], [27, 0], [28, 0], [29, 0], [29, 10], [29, 11], [29, 12], [29, 13], [29, 14], [15, 0], [15, 1], [15, 2], [15, 3], [15, 4], [15, 5], [15, 6], [15, 7], [15, 8], [15, 9], [0, 10], [1, 10], [2, 10], [3, 10], [4, 10], [5, 10], [6, 10], [7, 10], [8, 10], [9, 10], [10, 10], [11, 10], [12, 10], [13, 10], [14, 10], [15, 10], [0, 20], [1, 20], [2, 20], [3, 20], [4, 20], [5, 20], [6, 20], [7, 20], [8, 20], [9, 20], [10, 20], [11, 20], [12, 20], [13, 20], [14, 20], [15, 20], [16, 20], [17, 20], [18, 20], [19, 20], [20, 20], [21, 20], [22, 20], [23, 20], [24, 20], [25, 20], [26, 20], [27, 20], [28, 20], [29, 20]]
        }
      ];
      this.map = this.maps[0];
      this.refresh();
      addEventListener("keydown", this.handleButtonKeyDown, false);
    }

    App.prototype.createDom = function(DomCreator) {
      this.domCreator = new DomCreator("snakeGame");
      this.domCreator.createPara("空格暂停/开始，回车重来");
      this.domCreator.createPara("WASD、方向键或划屏操纵");
      this.scoreBar = this.domCreator.createSpan("score");
      this.canvas = this.domCreator.createCanvas(300, 300, "snakeCanvas");
      this.ctx = this.canvas.getContext("2d");
      this.switchButton = this.domCreator.createButton("switch", "btn btn-danger");
      this.refreshButton = this.domCreator.createButton("refresh", "btn btn-danger");
      this.domCreator.createPara("选择速度");
      this.speedRadio = [this.domCreator.createRadio("speed", "low", "低", "speed0"), this.domCreator.createRadio("speed", "mid", "中", "speed1", true), this.domCreator.createRadio("speed", "high", "高", "speed2")];
      this.domCreator.createPara("选择地图");
      this.mapRadio = [this.domCreator.createRadio("map", "map0", "无地图", "map0", true), this.domCreator.createRadio("map", "map1", "地图一", "map1"), this.domCreator.createRadio("map", "map2", "地图二", "map2")];
      this.speedRadio[0].onclick = this.setSpeed;
      this.speedRadio[1].onclick = this.setSpeed;
      this.speedRadio[2].onclick = this.setSpeed;
      this.mapRadio[0].onclick = this.setMap;
      this.mapRadio[1].onclick = this.setMap;
      return this.mapRadio[2].onclick = this.setMap;
    };

    App.prototype.fixPos = function(point) {
      point[0] %= this.unitNum;
      point[1] %= this.unitNum;
      while (point[0] < 0) {
        point[0] += this.unitNum;
      }
      while (point[1] < 0) {
        point[1] += this.unitNum;
      }
      return point;
    };

    App.prototype.createSnake = function() {
      var headX, headY, i, k, list, move;
      list = [];
      if (this.map.head != null) {
        headX = this.map.head[0];
        headY = this.map.head[1];
      } else {
        headX = Math.floor(Math.random() * this.unitNum);
        headY = Math.floor(Math.random() * this.unitNum);
      }
      if (this.map.move != null) {
        move = this.map.move;
      } else {
        move = this.directions[Math.floor(Math.random() * this.directions.length)];
      }
      for (i = k = 0; k < 4; i = ++k) {
        switch (move) {
          case "UP":
            list.push(this.fixPos([headX, headY + i]));
            break;
          case "DOWN":
            list.push(this.fixPos([headX, headY - i]));
            break;
          case "LEFT":
            list.push(this.fixPos([headX + i, headY]));
            break;
          case "RIGHT":
            list.push(this.fixPos([headX - i, headY]));
        }
      }
      this.snake.list = list;
      return this.snake.move = move;
    };

    App.prototype.createFood = function() {
      var results;
      this.food = [Math.floor(Math.random() * this.unitNum), Math.floor(Math.random() * this.unitNum)];
      results = [];
      while (this.checkFoodCollision()) {
        results.push(this.food = [Math.floor(Math.random() * this.unitNum), Math.floor(Math.random() * this.unitNum)]);
      }
      return results;
    };

    App.prototype.checkFoodCollision = function() {
      var body, brick, k, l, len, len1, ref, ref1;
      ref = this.snake.list;
      for (k = 0, len = ref.length; k < len; k++) {
        body = ref[k];
        if (this.food[0] === body[0] && this.food[1] === body[1]) {
          return true;
        }
      }
      ref1 = this.map.wall;
      for (l = 0, len1 = ref1.length; l < len1; l++) {
        brick = ref1[l];
        if (this.food[0] === brick[0] && this.food[1] === brick[1]) {
          return true;
        }
      }
      return false;
    };

    App.prototype.changeSnakeMove = function() {
      while (this.moveQueue.length && (this.snake.move === this.opposite[this.moveQueue[0]] || this.moveQueue[0] === this.moveQueue[1] || this.snake.move === this.moveQueue[0])) {
        this.moveQueue.shift();
      }
      if (this.moveQueue.length) {
        return this.snake.move = this.moveQueue.shift();
      }
    };

    App.prototype.insertSnakeHead = function() {
      var headX, headY;
      headX = this.snake.list[0][0];
      headY = this.snake.list[0][1];
      switch (this.snake.move) {
        case "UP":
          return this.snake.list.unshift(this.fixPos([headX, headY - 1]));
        case "DOWN":
          return this.snake.list.unshift(this.fixPos([headX, headY + 1]));
        case "LEFT":
          return this.snake.list.unshift(this.fixPos([headX - 1, headY]));
        case "RIGHT":
          return this.snake.list.unshift(this.fixPos([headX + 1, headY]));
      }
    };

    App.prototype.checkHeadCollision = function() {
      var body, brick, k, l, len, len1, ref, ref1;
      ref = this.snake.list.slice(1, this.snake.list.length - 1);
      for (k = 0, len = ref.length; k < len; k++) {
        body = ref[k];
        if (this.snake.list[0][0] === body[0] && this.snake.list[0][1] === body[1]) {
          return -1;
        }
      }
      ref1 = this.map.wall;
      for (l = 0, len1 = ref1.length; l < len1; l++) {
        brick = ref1[l];
        if (this.snake.list[0][0] === brick[0] && this.snake.list[0][1] === brick[1]) {
          return -1;
        }
      }
      if (this.snake.list[0][0] === this.food[0] && this.snake.list[0][1] === this.food[1]) {
        return 1;
      }
      return 0;
    };

    App.prototype.deleteSnakeTail = function() {
      return this.snake.list.pop();
    };

    App.prototype.moveSnake = function() {
      this.changeSnakeMove();
      this.insertSnakeHead();
      switch (this.checkHeadCollision()) {
        case 1:
          this.score++;
          this.scoreBar.innerHTML = this.score + " 分";
          return this.createFood();
        case 0:
          return this.deleteSnakeTail();
        case -1:
          this.deleteSnakeTail();
          return -1;
      }
    };

    App.prototype.renderPresent = function() {
      var body, brick, i, j, k, l, len, len1, m, n, ref, ref1, ref2, ref3;
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      for (i = k = 0, ref = this.unitNum; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        for (j = l = 0, ref1 = this.unitNum; 0 <= ref1 ? l < ref1 : l > ref1; j = 0 <= ref1 ? ++l : --l) {
          if ((i + j) % 2) {
            this.ctx.fillStyle = "rgba(200, 200, 200, 0.5)";
          } else {
            this.ctx.fillStyle = "rgba(255, 255, 255, 0.5)";
          }
          this.ctx.fillRect(i * this.unitSize, j * this.unitSize, this.unitSize, this.unitSize);
        }
      }
      ref2 = this.map.wall;
      for (m = 0, len = ref2.length; m < len; m++) {
        brick = ref2[m];
        this.ctx.fillStyle = "rgba(3, 3, 3, 0.7)";
        this.ctx.fillRect(brick[0] * this.unitSize, brick[1] * this.unitSize, this.unitSize, this.unitSize);
      }
      this.ctx.strokeStyle = "rgba(0, 100, 100, 1)";
      this.ctx.strokeRect(this.food[0] * this.unitSize, this.food[1] * this.unitSize, this.unitSize, this.unitSize);
      ref3 = this.snake.list.slice(1, this.snake.list.length);
      for (n = 0, len1 = ref3.length; n < len1; n++) {
        body = ref3[n];
        this.ctx.fillStyle = "rgba(100, 100, 200, 1)";
        this.ctx.fillRect(body[0] * this.unitSize, body[1] * this.unitSize, this.unitSize, this.unitSize);
      }
      this.ctx.fillStyle = "rgba(200, 0, 0, 1)";
      this.ctx.fillRect(this.snake.list[0][0] * this.unitSize, this.snake.list[0][1] * this.unitSize, this.unitSize, this.unitSize);
      this.ctx.strokeStyle = "rgba(3, 3, 3, 0.7)";
      return this.ctx.strokeRect(0, 0, this.canvas.width, this.canvas.height);
    };

    App.prototype.handleButtonKeyDown = function(event) {
      switch (event.keyCode) {
        case 32:
          event.preventDefault();
          return this.switchButton.onclick();
        case 13:
          event.preventDefault();
          return this.refreshButton.onclick();
      }
    };

    App.prototype.handleMoveKeyDown = function(event) {
      var move;
      switch (event.keyCode) {
        case 38:
          move = "UP";
          break;
        case 40:
          move = "DOWN";
          break;
        case 37:
          move = "LEFT";
          break;
        case 39:
          move = "RIGHT";
          break;
        case 87:
          move = "UP";
          break;
        case 83:
          move = "DOWN";
          break;
        case 65:
          move = "LEFT";
          break;
        case 68:
          move = "RIGHT";
      }
      if (move != null) {
        event.preventDefault();
        return this.moveQueue.push(move);
      }
    };

    App.prototype.handleTouchStart = function(event) {
      if (event.touches.length > 1 || event.targetTouches.length > 1) {
        return -1;
      }
      this.touchStart = [event.touches[0].clientX, event.touches[0].clientY];
      return event.preventDefault();
    };

    App.prototype.handleTouchMove = function(event) {
      return event.preventDefault();
    };

    App.prototype.handleTouchEnd = function(event) {
      var absDx, absDy, dx, dy, move;
      if (event.touches.length > 0 || event.targetTouches.length > 0) {
        return -1;
      }
      dx = event.changedTouches[0].clientX - this.touchStart[0];
      dy = event.changedTouches[0].clientY - this.touchStart[1];
      absDx = Math.abs(dx);
      absDy = Math.abs(dy);
      this.touchStart = [];
      if (Math.max(absDx, absDy) > 30) {
        move = (absDx > absDy ? (dx > 0 ? "RIGHT" : "LEFT") : (dy > 0 ? "DOWN" : "UP"));
        event.preventDefault();
        return this.moveQueue.push(move);
      }
    };

    App.prototype.setSpeed = function() {
      if (this.speedRadio[0].checked) {
        this.interval = 200;
        return this.refresh();
      } else if (this.speedRadio[2].checked) {
        this.interval = 100;
        return this.refresh();
      } else {
        this.interval = 150;
        return this.refresh();
      }
    };

    App.prototype.setMap = function() {
      if (this.mapRadio[1].checked) {
        this.map = this.maps[1];
        return this.refresh();
      } else if (this.mapRadio[2].checked) {
        this.map = this.maps[2];
        return this.refresh();
      } else {
        this.map = this.maps[0];
        return this.refresh();
      }
    };

    App.prototype.main = function() {
      var result;
      result = this.moveSnake();
      this.renderPresent();
      if (result === -1) {
        return this.death();
      }
    };

    App.prototype.start = function() {
      addEventListener("keydown", this.handleMoveKeyDown, false);
      this.canvas.addEventListener("touchstart", this.handleTouchStart, false);
      this.canvas.addEventListener("touchmove", this.handleTouchMove, false);
      this.canvas.addEventListener("touchend", this.handleTouchEnd, false);
      this.timerId = setInterval(this.main, this.interval);
      this.switchButton.innerHTML = "暂停";
      return this.switchButton.onclick = this.stop;
    };

    App.prototype.stop = function() {
      removeEventListener("keydown", this.handleMoveKeyDown, false);
      this.canvas.removeEventListener("touchstart", this.handleTouchStart, false);
      this.canvas.removeEventListener("touchmove", this.handleTouchMove, false);
      this.canvas.removeEventListener("touchend", this.handleTouchEnd, false);
      clearInterval(this.timerId);
      this.switchButton.innerHTML = "继续";
      return this.switchButton.onclick = this.start;
    };

    App.prototype.death = function() {
      var img;
      removeEventListener("keydown", this.handleMoveKeyDown, false);
      this.canvas.removeEventListener("touchstart", this.handleTouchStart, false);
      this.canvas.removeEventListener("touchmove", this.handleTouchMove, false);
      this.canvas.removeEventListener("touchend", this.handleTouchEnd, false);
      clearInterval(this.timerId);
      this.switchButton.innerHTML = "死啦";
      this.switchButton.onclick = this.refresh;
      img = new Image();
      img.onload = (function(_this) {
        return function() {
          var str, text, topBase;
          _this.ctx.fillStyle = "rgba(255, 255, 255, 0.3)";
          _this.ctx.fillRect(0, 0, _this.canvas.width, _this.canvas.height);
          _this.ctx.fillStyle = "rgba(3, 3, 3, 0.7)";
          _this.ctx.font = "30px sans";
          _this.ctx.textAlign = "start";
          _this.ctx.textBaseline = "top";
          topBase = Math.floor((_this.canvas.height - img.height - 10 - 30 - 10 - 30) / 2);
          str = "你获得了 " + _this.score + " 分";
          text = _this.ctx.measureText(str);
          _this.ctx.fillText(str, Math.floor((_this.canvas.width - text.width) / 2), topBase);
          str = "截图分享给朋友吧";
          text = _this.ctx.measureText(str);
          _this.ctx.fillText(str, Math.floor((_this.canvas.width - text.width) / 2), topBase + 30 + 10);
          _this.ctx.fillStyle = "rgba(10, 10, 10, 0.5)";
          str = "你获得了 " + _this.score + " 分";
          text = _this.ctx.measureText(str);
          _this.ctx.fillText(str, Math.floor((_this.canvas.width - text.width) / 2) + 2, topBase + 2);
          str = "截图分享给朋友吧";
          text = _this.ctx.measureText(str);
          _this.ctx.fillText(str, Math.floor((_this.canvas.width - text.width) / 2) + 2, topBase + 30 + 10 + 2);
          return _this.ctx.drawImage(img, Math.floor((_this.canvas.width - img.width) / 2), topBase + 30 + 10 + 30 + 10);
        };
      })(this);
      return img.src = "images/qrcode_transparent.png";
    };

    App.prototype.refresh = function() {
      if (this.timerId != null) {
        clearInterval(this.timerId);
      }
      this.moveQueue = [];
      this.food = [];
      this.snake = {};
      this.score = 0;
      this.scoreBar.innerHTML = this.score + " 分";
      this.createSnake();
      this.createFood();
      this.renderPresent();
      this.switchButton.innerHTML = "开始";
      this.switchButton.onclick = this.start;
      this.refreshButton.innerHTML = "重来";
      return this.refreshButton.onclick = this.refresh;
    };

    return App;

  })();

  app = new App(DomCreator);

}).call(this);
