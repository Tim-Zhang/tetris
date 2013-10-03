// Generated by CoffeeScript 1.6.3
(function() {
  $(function() {
    var APP, BASE, CONFIG, allPieces, centerComponent, check, checkFailed, clearLines, compiled, component, componentHandle, computeScore, draw, drawBase, dropBase, erase, fail, flash, genComponent, getFilled, getTapRelPos, hideInfo, landed, move, moveDown, moveLeft, moveRight, nextComponent, paintColor, pause, previewNext, rebase, restart, resume, setBase, showBtn, showInfo, showScore, start, startFlash, stopDefault, transform;
    CONFIG = {
      row: 21,
      col: 12,
      scoreMap: [1, 2, 4, 8],
      keyMap: {
        up: 38,
        down: 40,
        left: 37,
        right: 39,
        space: 32
      }
    };
    APP = {
      status: 0,
      score: 0,
      next: null,
      timer: null
    };
    component = null;
    nextComponent = null;
    BASE = [];
    allPieces = [
      [
        {
          x: 0,
          y: 0
        }, {
          x: 1,
          y: 0
        }, {
          x: 2,
          y: 0
        }, {
          x: 3,
          y: 0
        }
      ], [
        {
          x: 0,
          y: 0
        }, {
          x: 1,
          y: 0
        }, {
          x: 2,
          y: 0
        }, {
          x: 2,
          y: 1
        }
      ], [
        {
          x: 0,
          y: 0
        }, {
          x: 1,
          y: 0
        }, {
          x: 2,
          y: 0
        }, {
          x: 0,
          y: 1
        }
      ], [
        {
          x: 0,
          y: 0
        }, {
          x: 1,
          y: 0
        }, {
          x: 0,
          y: 1
        }, {
          x: 1,
          y: 1
        }
      ], [
        {
          x: 1,
          y: 0
        }, {
          x: 2,
          y: 0
        }, {
          x: 0,
          y: 1
        }, {
          x: 1,
          y: 1
        }
      ], [
        {
          x: 0,
          y: 0
        }, {
          x: 1,
          y: 0
        }, {
          x: 2,
          y: 0
        }, {
          x: 1,
          y: 1
        }
      ], [
        {
          x: 0,
          y: 1
        }, {
          x: 1,
          y: 1
        }, {
          x: 1,
          y: 2
        }, {
          x: 2,
          y: 2
        }
      ]
    ];
    centerComponent = function(component) {
      var center, length, maxX, newXstart;
      center = Math.floor(CONFIG.col / 2);
      maxX = _.max(component, function(c) {
        return c.x;
      }).x;
      length = maxX + 1;
      newXstart = center - Math.floor(length / 2);
      return _.map(component, function(c) {
        return {
          x: c.x + newXstart,
          y: c.y
        };
      });
    };
    genComponent = function() {
      var random;
      if (!checkFailed()) {
        random = _.random(0, 6);
        return allPieces[random];
      } else {
        return fail();
      }
    };
    paintColor = function(block, color) {
      var b, table, _i, _len;
      table = $('.gamearea table').get(0);
      for (_i = 0, _len = block.length; _i < _len; _i++) {
        b = block[_i];
        table.rows[b.y].cells[b.x].style.backgroundColor = color;
        null;
      }
      return null;
    };
    draw = function(component) {
      if (APP.status === 1) {
        return paintColor(component, 'blue');
      }
    };
    moveDown = function() {
      if (APP.status === 1) {
        erase(component);
        move('down');
        return draw(component);
      }
    };
    moveLeft = function() {
      erase(component);
      move('left');
      return draw(component);
    };
    moveRight = function() {
      erase(component);
      move('right');
      return draw(component);
    };
    move = function(direction) {
      var check_result, tmpComponent;
      tmpComponent = [];
      switch (direction) {
        case 'down':
          tmpComponent = _.map(component, function(c) {
            return {
              x: c.x,
              y: c.y + 1
            };
          });
          break;
        case 'left':
          tmpComponent = _.map(component, function(c) {
            return {
              x: c.x - 1,
              y: c.y
            };
          });
          break;
        case 'right':
          tmpComponent = _.map(component, function(c) {
            return {
              x: c.x + 1,
              y: c.y
            };
          });
      }
      check_result = check(tmpComponent);
      if (check_result) {
        return component = tmpComponent;
      } else if (direction === 'down') {
        return landed();
      }
    };
    landed = function() {
      var filled;
      setBase();
      filled = getFilled();
      if (filled.length) {
        computeScore(filled);
        clearLines(filled);
      }
      return componentHandle();
    };
    componentHandle = function() {
      if (nextComponent) {
        component = centerComponent(nextComponent);
        nextComponent = genComponent();
      } else {
        component = centerComponent(genComponent());
        nextComponent = genComponent();
      }
      previewNext(nextComponent);
      return console.log(nextComponent);
    };
    previewNext = function(component) {
      var $preview, b, color, preview, _i, _len;
      if (!component) {
        return;
      }
      $preview = $('.preview table');
      $preview.find('td').css('background-color', 'white');
      preview = $preview.get(0);
      color = 'blue';
      for (_i = 0, _len = component.length; _i < _len; _i++) {
        b = component[_i];
        preview.rows[b.y].cells[b.x].style.backgroundColor = color;
        null;
      }
      return null;
    };
    computeScore = function(filled) {
      APP.score += CONFIG.scoreMap[filled.length - 1];
      return showScore(APP.score);
    };
    showScore = function(score) {
      return $('#score').text(score);
    };
    clearLines = function(filled) {
      var domTrs, willClear;
      domTrs = $('table tr');
      willClear = $('');
      _.each(filled, function(row) {
        return willClear = willClear.add(domTrs.eq(row));
      });
      flash(willClear).find('td').css({
        'background-color': 'white'
      });
      return dropBase(filled);
    };
    dropBase = function(filled) {
      _.each(filled, function(row) {
        var i, j, _i, _results;
        _results = [];
        for (i = _i = row; row <= 0 ? _i < 0 : _i > 0; i = row <= 0 ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref, _results1;
            _results1 = [];
            for (j = _j = 0, _ref = CONFIG.col; 0 <= _ref ? _j < _ref : _j > _ref; j = 0 <= _ref ? ++_j : --_j) {
              _results1.push(BASE[i][j] = BASE[i - 1][j]);
            }
            return _results1;
          })());
        }
        return _results;
      });
      return drawBase();
    };
    flash = function(object, times) {
      var i, _i;
      if (times == null) {
        times = 0;
      }
      for (i = _i = 0; 0 <= times ? _i <= times : _i >= times; i = 0 <= times ? ++_i : --_i) {
        object.fadeOut(150).fadeIn(150);
      }
      return object;
    };
    setBase = function() {
      _.each(component, function(block) {
        return BASE[block.y][block.x] = 1;
      });
      return drawBase();
    };
    transform = function() {
      var center_block, check_result, distinctX, distinctY, sumX, sumY, tmpComponent;
      distinctX = _.uniq(_.pluck(component, 'x'));
      distinctY = _.uniq(_.pluck(component, 'y'));
      sumX = _.reduce(distinctX, (function(mem, x) {
        return mem + x;
      }), 0);
      sumY = _.reduce(distinctY, (function(mem, y) {
        return mem + y;
      }), 0);
      center_block = {
        x: Math.floor(sumX / distinctX.length),
        y: Math.ceil(sumY / distinctY.length)
      };
      tmpComponent = _.map(component, function(block) {
        return {
          x: center_block.x + center_block.y - block.y,
          y: center_block.y + block.x - center_block.x - (distinctY.length % 2 === 0 ? 1 : 0)
        };
      });
      check_result = check(tmpComponent);
      if (check_result) {
        erase(component);
        component = tmpComponent;
        return draw(component);
      } else {
        return console.log(1);
      }
    };
    check = function(tmpComponent) {
      return _.every(tmpComponent, function(block) {
        var not_over, _ref, _ref1;
        not_over = (0 <= (_ref = block.x) && _ref < CONFIG.col) && (0 <= (_ref1 = block.y) && _ref1 < CONFIG.row);
        return not_over && BASE[block.y][block.x] === 0;
      });
    };
    checkFailed = function() {
      return _.compact(BASE[0]).length;
    };
    erase = function(component) {
      return paintColor(component, 'white');
    };
    drawBase = function() {
      var filled, table, x, xArray, y;
      table = $('.gamearea table').get(0);
      for (y in BASE) {
        xArray = BASE[y];
        for (x in xArray) {
          filled = xArray[x];
          if (filled === 1) {
            table.rows[y].cells[x].style.backgroundColor = '#888';
          } else {
            table.rows[y].cells[x].style.backgroundColor = '#fff';
          }
          null;
        }
      }
      return null;
    };
    getFilled = function() {
      var domTrs, filledList, willClear;
      filledList = [];
      domTrs = $('table tr');
      willClear = $('');
      _.each(BASE, function(row, y) {
        if ((_.compact(row)).length === CONFIG.col) {
          return filledList.push(y);
        }
      });
      return filledList;
    };
    compiled = _.template($('#template-board').html());
    $('#board').html(compiled(_.extend({}, CONFIG, APP)));
    $(document).keydown(function(e) {
      var keyCode, keyMap;
      keyMap = CONFIG.keyMap;
      keyCode = e.which;
      if (_.contains(keyMap, keyCode)) {
        e.preventDefault();
      }
      if (APP.status !== 1) {
        return;
      }
      switch (keyCode) {
        case keyMap.left:
          return moveLeft();
        case keyMap.up:
          return transform();
        case keyMap.right:
          return moveRight();
        case keyMap.down:
          return moveDown();
        case keyMap.space:
          return _(3).times(moveDown);
      }
    });
    rebase = function() {
      var c, r, _i, _j, _ref, _ref1;
      for (r = _i = 0, _ref = CONFIG.row; 0 <= _ref ? _i < _ref : _i > _ref; r = 0 <= _ref ? ++_i : --_i) {
        for (c = _j = 0, _ref1 = CONFIG.col; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; c = 0 <= _ref1 ? ++_j : --_j) {
          if (BASE[r] == null) {
            BASE[r] = [];
          }
          BASE[r][c] = 0;
        }
      }
      return $('.gamearea td').css({
        'background-color': 'white'
      });
    };
    start = function() {
      APP.score = 0;
      showScore(APP.score);
      rebase();
      APP.status = 1;
      componentHandle();
      draw(component);
      return APP.timer = setInterval((function() {
        return moveDown(component);
      }), 1000);
    };
    pause = function() {
      return APP.status = 2;
    };
    resume = function() {
      return APP.status = 1;
    };
    restart = function() {
      return rebase();
    };
    fail = function() {
      clearInterval(APP.timer);
      APP.status = 3;
      showInfo('You Lost');
      showBtn('start');
      return null;
    };
    showInfo = function(info) {
      return $('.backdrop').find('.message').text(info).end().show();
    };
    hideInfo = function(info) {
      return $('.backdrop').hide();
    };
    startFlash = function(callback) {
      var domBackdrop, domMessage;
      domBackdrop = $('.backdrop');
      domMessage = domBackdrop.find('.message');
      domMessage.text('Ready');
      return _.delay((function() {
        domMessage.text('Go!');
        return _.delay((function() {
          domBackdrop.hide();
          return callback();
        }), 300);
      }), 300);
    };
    showBtn = function(type) {
      $('button').hide();
      return $("[data-action=" + type + "]").show();
    };
    $('button').click(function(e) {
      var action, target;
      target = $(this);
      action = target.data('action');
      switch (action) {
        case 'start':
          if (APP.status === 0) {
            startFlash(start);
          } else if (APP.status === 2) {
            resume();
            hideInfo();
          } else if (APP.status === 3) {
            startFlash(start);
          }
          return showBtn('pause');
        case 'pause':
          if (APP.status === 1) {
            pause();
            showBtn('start');
            return showInfo('Pause');
          }
      }
    });
    $('#btn-start').click(function(e) {});
    getTapRelPos = function(pos) {
      var $gamearea, height, left, relative, top, width;
      $gamearea = $('.gamearea');
      top = $gamearea.position().top;
      left = $gamearea.position().left;
      height = $gamearea.height();
      width = $gamearea.width();
      relative = null;
      if (pos.pageY > top + height) {
        relative = 'down';
      } else if (pos.pageX < left) {
        relative = 'left';
      } else if (pos.pageX > left + width) {
        relative = 'right';
      } else {
        relative = 'up';
      }
      return relative;
    };
    stopDefault = function(ev) {
      ev.stopPropagation();
      ev.preventDefault();
      ev.gesture.stopPropagation();
      ev.gesture.preventDefault();
      return ev.gesture.stopDetect();
    };
    Hammer(document).on("doubletap", function(event) {
      return stopDefault(event);
    });
    Hammer(document).on("touch", function(event) {
      return stopDefault(event);
    });
    return Hammer(document).on("tap", function(event) {
      var relative;
      if (APP.status !== 1) {
        return;
      }
      event.preventDefault();
      relative = getTapRelPos(event.gesture.center);
      switch (relative) {
        case 'left':
          moveLeft();
          break;
        case 'up':
          transform();
          break;
        case 'right':
          moveRight();
          break;
        case 'down':
          moveDown();
      }
      return null;
    });
  });

}).call(this);
