$(() -> 
  # config
  CONFIG = 
    row: 21
    col: 12

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
    random = _.random(0, 3)
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
      setBase()
      component = genComponent()

    
  setBase = ->
    _.each component, (block) ->
      BASE[block.x][block.y] = 1
    drawBase()

    
    
    

  transform = () ->
    

  # check
  check = (tmpComponent) ->
    _.every tmpComponent, (block) ->
      not_over = 0 <= block.x < CONFIG.col and 0 <= block.y < CONFIG.row
      not_over and BASE[block.x][block.y] is 0
    

    
  # erase
  erase = (component) ->
    paintColor(component, 'white')
     
    
    
     

  drawBase = () ->
    for x, yArray of BASE
      for y, filled of yArray
        if filled is 1
          $("#coord-#{x}-#{y}").css({'background-color': 'blue'});
        
    

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
  for c in [0...CONFIG.col]
    for r in [0...CONFIG.row]
      BASE[c] ?= []
      BASE[c][r] = 0

  draw component
  APP.timer = setInterval (-> moveDown(component)), 1000
)


    
