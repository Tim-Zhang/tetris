$(() -> 
  # config
  CONFIG = 
    row: 21
    col: 12
    score: [
      1
      2
      4
      8
    ]

  APP = 
    status: 0
    score: 0
    next: null
    timer: null

  component = null

 
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
      {x: 0, y: 0}
      {x: 1, y: 0}
      {x: 1, y: 1}
      {x: 2, y: 1}
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
    random = _.random(0, 6)
    #random = 3
    piece = allPieces[random]
    centerComponent piece
  

  # paintColor
  paintColor = (block, color) ->
    for b in block
      $("#coord-#{b.x}-#{b.y}").css({'background-color': color});


  # draw
  draw = (component) ->
    paintColor(component, 'blue')

  # down
  moveDown = () ->
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
    component = genComponent()

  computeScore = (filled) ->
    APP.score += CONFIG.score[filled.length - 1]
    console.log APP.score, 'computed'


  clearLines = (filled) ->
    domTrs = $ 'table tr'
    willClear = $ ''

    _.each filled, (row) ->
      willClear = willClear.add domTrs.eq row

    flash(willClear).find('td').css({'background-color': 'white'})
    resetBase filled

  resetBase = (filled) ->
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
    

    
  # erase
  erase = (component) ->
    paintColor(component, 'white')
     

  drawBase = () ->
    for x, yArray of BASE
      for y, filled of yArray
        if filled is 1
          $("#coord-#{y}-#{x}").css({'background-color': 'blue'});
        else
          $("#coord-#{y}-#{x}").css({'background-color': 'white'});
          

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
  $('#board').html(compiled(CONFIG));

  # keyboard event
  $(document).keydown (e) ->
    if APP.status is 0
      return
    switch e.which
      when 37 then moveLeft()
      when 38 then transform()
      when 39 then moveRight()
      when 40 then moveDown()
      

  # start
  APP.status = 1
  component = genComponent()

  BASE = [] 
  for r in [0...CONFIG.row]
    for c in [0...CONFIG.col]
      BASE[r] ?= []
      BASE[r][c] = 0

  draw component
  APP.timer = setInterval (-> moveDown(component)), 1000
)


    
