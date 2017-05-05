{extend, addClass, removeClass, hasClass, Evented} = Tether.Utils

touchDevice = 'ontouchstart' of document.documentElement
clickEvent = if touchDevice then 'touchstart' else 'click'

sortAttach = (str) ->
  [first, second] = str.split(' ')

  if first in ['left', 'right']
    [first, second] = [second, first]

  [first, second].join(' ')

MIRROR_ATTACH =
  left: 'right'
  right: 'left'
  top: 'bottom'
  bottom: 'top'
  middle: 'middle'
  center: 'center'

allDrops = []

# Drop can be included in external libraries.  Calling createContext gives you a fresh
# copy of drop which won't interact with other copies on the page (beyond calling the document events).
createContext = (options) ->
  drop = ->
    new DropInstance arguments...

  extend drop,
    createContext: createContext
    drops: []

  defaultOptions =
    defaults:
      attach: 'bottom left'
      openOn: 'click'
      constrainToScrollParent: true
      constrainToWindow: true
      className: ''
      tetherOptions: {}

  extend true, drop, defaultOptions, options

  drop.updateBodyClasses = ->
    # There is only one body, so despite the context concept, we still iterate through all
    # drops created in any context before applying the class.

    anyOpen = false
    for _drop in allDrops when _drop.isOpened()
      anyOpen = true
      break

    if anyOpen
      addClass document.body, 'drop-open'
    else
      removeClass document.body, 'drop-open'

  class DropInstance extends Evented
    constructor: (@options) ->
      @options = extend {}, drop.defaults, @options

      {@target} = @options

      drop.drops.push @
      allDrops.push @

      @setupElements()
      @setupEvents()
      @setupTether()

    setupElements: ->
      @drop = document.createElement 'div'
      addClass @drop, 'drop'

      if @options.className
        addClass @drop, @options.className

      @dropContent = document.createElement 'div'
      addClass @dropContent, 'drop-content'
      if typeof @options.content is 'object'
        @dropContent.appendChild @options.content
      else
        @dropContent.innerHTML = @options.content

      @drop.appendChild @dropContent

    setupTether: ->
      # Tether expects two attachment points, one in the target element, one in the
      # drop.  We use a single one, and use the order as well, to allow us to put
      # the drop on either side of any of the four corners.  This magic converts between
      # the two:
      dropAttach = @options.attach.split(' ')
      dropAttach[0] = MIRROR_ATTACH[dropAttach[0]]
      dropAttach = dropAttach.join(' ')

      constraints = []
      if @options.constrainToScrollParent
        constraints.push
          to: 'scrollParent'
          pin: 'top, bottom'
          attachment: 'together none'

      if @options.constrainToWindow isnt false
        constraints.push
          to: 'window'
          pin: true
          attachment: 'together'

      # To get 'out of bounds' classes
      constraints.push
        to: 'scrollParent'

      options =
        element: @drop
        target: @target
        attachment: sortAttach(dropAttach)
        targetAttachment: sortAttach(@options.attach)
        offset: '0 0'
        targetOffset: '0 0'
        enabled: false
        constraints: constraints

      @tether = new Tether extend {}, options, @options.tetherOptions

    setupEvents: ->
      return unless @options.openOn
      events = @options.openOn.split ' '

      if 'click' in events
        @target.addEventListener clickEvent, => @toggle()

        document.addEventListener clickEvent, (event) =>
          return unless @isOpened()

          # Clicking inside dropdown
          if event.target is @drop or @drop.contains(event.target)
            return

          # Clicking target
          if event.target is @target or @target.contains(event.target)
            return

          @close()

      if 'hover' in events
        @target.addEventListener 'mouseover', => @open()
        @target.addEventListener 'mouseout', => @close()

    isOpened: ->
      hasClass @drop, 'drop-open'

    toggle: ->
      if @isOpened()
        @close()
      else
        @open()

    open: ->
      unless @drop.parentNode
        document.body.appendChild @drop

      addClass @target, 'drop-open'
      addClass @drop, 'drop-open'

      @trigger 'open'

      @tether.enable()

      drop.updateBodyClasses()

    close: ->
      removeClass @target, 'drop-open'
      removeClass @drop, 'drop-open'

      @trigger 'close'

      @tether.disable()

      drop.updateBodyClasses()

  drop

window.Drop = createContext()

document.addEventListener 'DOMContentLoaded', ->
  Drop.updateBodyClasses()
