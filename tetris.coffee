$(() -> 
  # config
  CONFIG = 
    row: 21
    col: 12
    
    scoreMap: [
      1
      2
      4
      8
    ]

    keyMap:
      up    :  38
      down  :  40 
      left  :  37
      right :  39
      space :  32

  APP = 
    status: 0 # 0: init | 1: running | 2: paused | 3: lost
    score: 0
    next: null
    timer: null

  component = null
  nextComponent = null
  BASE = []

 
  allPieces = [
    # I 
    [
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 2, y: 0}
      {x: 3, y: 0}
    ]
    # J 
    [
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 2, y: 0}
      {x: 2, y: 1}
    ]
    # L 
    [
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 2, y: 0}
      {x: 0, y: 1}
    ]
    # O 
    [
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 0, y: 1}
      {x: 1, y: 1}
    ]
    # S 
    [
      {x: 1, y: 0}
      {x: 2, y: 0}
      {x: 0, y: 1}
      {x: 1, y: 1}
    ]
    # T 
    [
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 2, y: 0}
      {x: 1, y: 1}
    ]
    # Z 
    [
      {x: 0, y: 1}
      {x: 1, y: 1}
      {x: 1, y: 2}
      {x: 2, y: 2}
    ]
  ]

  # make component center
  centerComponent = (component) ->
    center = Math.floor(CONFIG.col / 2)
    maxX = _.max(component, (c) -> c.x).x
    length = maxX + 1;
    newXstart = center - Math.floor(length / 2)
    _.map(component, (c) -> {x: c.x + newXstart, y: c.y})
     
  # generage component
  genComponent = () -> 
    if not checkFailed()
      random = _.random(0, 6)
      #random = 6
      allPieces[random]
    else 
      fail()
  

  # paintColor
  paintColor = (block, color) ->
    table = $('.gamearea table').get 0
    for b in block
      table.rows[b.y].cells[b.x].style.backgroundColor = color
      null
    null


  # draw
  draw = (component) ->
    if APP.status is 1
      paintColor(component, 'blue')

  # down
  moveDown = () ->
    if APP.status is 1
      erase component 
      move 'down'
      draw component

  # left
  moveLeft = () ->
    erase component 
    move 'left'
    draw component

  # right
  moveRight = () ->
    erase component 
    move 'right'
    draw component

  move = (direction) ->
    tmpComponent = []
    switch direction
      when 'down'
        tmpComponent =  _.map component, (c) -> {x: c.x, y: c.y + 1}
      when 'left'
        tmpComponent =  _.map component, (c) -> {x: c.x - 1, y: c.y}
      when 'right'
        tmpComponent =  _.map component, (c) -> {x: c.x + 1, y: c.y}
        
    check_result = check tmpComponent
    if check_result
      component = tmpComponent
    else if direction is 'down'
      landed()

  landed = ->
    setBase()
    filled = getFilled()
    if filled.length
      computeScore filled
      clearLines filled 
    componentHandle()

  componentHandle = ->
    if nextComponent
      component = centerComponent nextComponent
      nextComponent = genComponent()
    else
      component = centerComponent genComponent()
      nextComponent = genComponent()

    previewNext nextComponent
    console.log nextComponent

  previewNext = (component) ->
    if not component
      return
    $preview = $ '.preview table'
    $preview.find('td').css 'background-color', 'white'
    preview = $preview.get 0
    color = 'blue'

    for b in component
      preview.rows[b.y].cells[b.x].style.backgroundColor = color
      null
    null



  computeScore = (filled) ->
    APP.score += CONFIG.scoreMap[filled.length - 1]
    showScore APP.score

  showScore = (score) ->
    $('#score').text score


  clearLines = (filled) ->
    domTrs = $ 'table tr'
    willClear = $ ''

    _.each filled, (row) ->
      willClear = willClear.add domTrs.eq row

    flash(willClear).find('td').css({'background-color': 'white'})
    dropBase filled

  dropBase = (filled) ->
    _.each filled, (row) ->
      for i in [row ... 0] 
        for j in [0 ... CONFIG.col]
          BASE[i][j] = BASE[i - 1][j]

    drawBase()


  flash = (object, times = 0) ->
    for i in [0..times]
      object.fadeOut(150).fadeIn(150)
    object

    
  setBase = ->
    _.each component, (block) ->
      BASE[block.y][block.x] = 1
    drawBase()
    

  transform = () ->
    distinctX = _.uniq _.pluck component, 'x'
    distinctY = _.uniq _.pluck component, 'y'
    sumX = _.reduce distinctX, ((mem, x) -> mem + x), 0
    sumY = _.reduce distinctY, ((mem, y) -> mem + y), 0
    
    center_block = {x: Math.floor(sumX / distinctX.length), y: Math.ceil(sumY / distinctY.length)}
    
    tmpComponent = _.map component, (block) -> 
      x: center_block.x + center_block.y - block.y
      y: center_block.y + block.x - center_block.x - if distinctY.length % 2 is 0 then 1 else 0

    check_result = check tmpComponent
    if check_result
      erase component
      component = tmpComponent 
      draw component
    else
      console.log 1

      
  # check
  check = (tmpComponent) ->
    _.every tmpComponent, (block) ->
      not_over = 0 <= block.x < CONFIG.col and 0 <= block.y < CONFIG.row
      not_over and BASE[block.y][block.x] is 0

  checkFailed = ->
    _.compact(BASE[0]).length
    
    
  # erase
  erase = (component) ->
    paintColor(component, 'white')
     

  drawBase = () ->
    table = $('.gamearea table').get 0
    for y, xArray of BASE
      for x, filled of xArray
        if filled is 1
          table.rows[y].cells[x].style.backgroundColor = '#888'
        else
          table.rows[y].cells[x].style.backgroundColor = '#fff'
        null
    null

  getFilled = ->
    filledList = []
    domTrs = $ 'table tr'
    willClear = $ ''

    _.each BASE, (row, y) ->
      if (_.compact row).length is CONFIG.col
        filledList.push(y)
    filledList

    

  # render board
  compiled = _.template($('#template-board').html());
  $('#board').html(compiled(_.extend({}, CONFIG, APP)));

  # keyboard event
  $(document).keydown (e) ->
    keyMap = CONFIG.keyMap
    keyCode = e.which
    if _.contains keyMap, keyCode
      e.preventDefault()
    if APP.status isnt 1
      return
    switch keyCode
      when keyMap.left   then moveLeft()
      when keyMap.up     then transform()
      when keyMap.right  then moveRight()
      when keyMap.down   then moveDown()
      when keyMap.space  then _(3).times moveDown

  rebase = ->
    for r in [0...CONFIG.row]
      for c in [0...CONFIG.col]
        BASE[r] ?= []
        BASE[r][c] = 0
    $('.gamearea td').css({'background-color': 'white'})

  # start
  start = ->
    APP.score = 0
    showScore APP.score
    rebase()
    APP.status = 1
    componentHandle()
    draw component
    APP.timer = setInterval (-> moveDown(component)), 1000

  # pause
  pause = ->
    APP.status = 2

  resume = ->
    APP.status = 1

  restart = ->
    rebase()

  fail = ->
    clearInterval APP.timer
    APP.status = 3
    showInfo 'You Lost'
    showBtn 'start'
    null

  showInfo = (info) ->
    $('.backdrop').find('.message').text(info).end().show()
    
  hideInfo = (info) ->
    $('.backdrop').hide()

  startFlash = (callback) ->
    domBackdrop = $ '.backdrop'
    domMessage = domBackdrop.find '.message'
    
    domMessage.text 'Ready'
    _.delay((->
      domMessage.text 'Go!'
      _.delay((->
        domBackdrop.hide()
        callback()
      ), 300)

    ), 300)
    
  showBtn = (type) ->
    $('button').hide()
    $("[data-action=#{type}]").show()

  
  # bind start event

  $('button').click (e) ->
    target = $(this)
    action = target.data('action');

    switch action
      when 'start' 
        if APP.status is 0
          startFlash(start)
        else if APP.status is 2
          resume()
          hideInfo()
        else if APP.status is 3
          startFlash(start)

        showBtn 'pause'
      when 'pause' 
        if APP.status is 1
          pause()
          showBtn 'start'
          showInfo 'Pause'
         

  $('#btn-start').click (e) ->

  getTapRelPos = (pos) ->
    $gamearea = $ '.gamearea'
    top = $gamearea.position().top
    left = $gamearea.position().left
    height = $gamearea.height()
    width = $gamearea.width()
    relative = null
    if pos.pageY > top + height
      relative = 'down'
    else if pos.pageX < left
      relative = 'left'
    else if pos.pageX > left + width
      relative = 'right'
    else
      relative = 'up'

    relative



  hammertime = Hammer(document).on "tap", (event) ->
    if APP.status isnt 1
      return
    event.preventDefault()
    relative =  getTapRelPos(event.gesture.center)
    switch relative
      when 'left'   then moveLeft()
      when 'up'     then transform()
      when 'right'  then moveRight()
      when 'down'   then moveDown()
    null

)


    
