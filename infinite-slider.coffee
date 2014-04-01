##
## <infinite-slider> attributes
##
##  acceleration  || 1.15       # "acceleration"  > 1
##  friction      || 0.95       # "friction" < 1
##  spring-back   || 0.1        # spring-back 0..1 1=fastest
##  click-fudge   || 2          # pixels of movement that still allow click
##  max-velocity  || 70         # maximum scrollwheel velocity
##  snap          || false      # per-item snapping **ONLY WORKS IF ALL ITEMS ARE THE SAME WIDTH
##
(->

  angular.module('gilbox.infiniteSlider.helpers', []).factory 'browserHelper', ['$window', ($window) ->
    _has3d = undefined

    has3d: ->   # perform check the first time the function is invoked
      return _has3d if _has3d isnt `undefined`
      return _has3d = (-> # http://stackoverflow.com/questions/5661671/detecting-transform-translate3d-support
        el = document.createElement("p")
        has3d = undefined
        transforms =
          webkitTransform: "-webkit-transform"
          OTransform: "-o-transform"
          msTransform: "-ms-transform"
          MozTransform: "-moz-transform"
          transform: "transform"
        document.body.insertBefore el, null
        for t of transforms
          if el.style[t] isnt `undefined`
            el.style[t] = "translate3d(1px,1px,1px)"
            has3d = $window.getComputedStyle(el).getPropertyValue(transforms[t])
        document.body.removeChild el
        has3d isnt `undefined` and has3d.length > 0 and has3d isnt "none")()

    getTouchPoint: (event) ->
      #console.log "-->event", event
      e = switch
        when event.touches?
          event.touches[0]
        when event.originalEvent? && event.originalEvent.touches? && event.originalEvent.touches.length
          event.originalEvent.touches[0]
        else event
      angular.extend e, {x: e.pageX, y: e.pageY}

  ] # /browserHelper

  angular.module('gilbox.infiniteSlider', ['monospaced.mousewheel', 'gilbox.infiniteSlider.helpers']).directive 'infiniteSlider', ['$window', '$document', 'browserHelper', ($window, $document, browserHelper) ->
    restrict: 'A'
    scope: {}
    replace: true
    transclude: true
    template: '<div ng-transclude msd-wheel="wheel($event, $delta, $deltaX, $deltaY)"></div>'
    link: (scope, element, attrs) ->

      a = attrs.acceleration || 1.05         # "acceleration"  > 1
      f = attrs.friction || 0.95            # "friction" < 1
      spring = attrs.springBack || 0.1      # spring-back 0..1 1=fastest
      clickFudge = attrs.clickFudge || 2    # pixels of movement that still allow click
      maxv = attrs.maxVelocity || 50        # maximum scrollwheel velocity
      snap = attrs.snap || false

      v = 0           # "velocity"
      xCont = 0
#      xMin = 0
      naxv = -maxv
      winElm = angular.element($window)
      contElm = element.children().eq(0)
      items = contElm.children()
      console.log "-->items", items
      window.itms = items
      endTypes = 'touchend touchcancel mouseup mouseleave'
      moveTypes = 'touchmove mousemove'
      startTypes = 'touchstart mousedown'
      moveTypesArray = moveTypes.split ' '
      allowClick = true
      interactionStart = null
      interactionCurrent = null
      prevInteraction = null
      xMin = 0
      xMax = 0
      firstItem = null
      lastItem = null
      itemWidth = 0

      has3d = browserHelper.has3d()

      $document.bind endTypes, (event) -> # drag end
        unless (allowClick)
          event.preventDefault()
          if (interactionStart == null || (Math.abs(interactionCurrent.x - interactionStart.x) < clickFudge && Math.abs(interactionCurrent.y - interactionStart.y) < clickFudge))
            allowClick = true # click now
            el = document.elementFromPoint(interactionCurrent.x, interactionCurrent.y);
            if el? and !interactionCurrent.button
              document.elementFromPoint(interactionCurrent.clientX, interactionCurrent.clientY).click();
          else
            v = prevInteraction.x - interactionCurrent.x  # momentum-generated velocity
            setTimeout (-> allowClick = true), 100  # don't allow click todo: seems hacky, a better way to do this?

        interactionStart = null
        for type in moveTypesArray
          $document.unbind type


      element.bind startTypes, (event) ->  # drag start
        event.preventDefault()
        allowClick = false
        v = 0
        elementStartX = xCont
        interactionStart = interactionCurrent = browserHelper.getTouchPoint event

        $document.bind moveTypes, (event) ->  # drag move
          event.preventDefault()
          prevInteraction = interactionCurrent if interactionCurrent
          interactionCurrent = browserHelper.getTouchPoint event

          if prevInteraction # viewport scrolling (up/down)
            dy = prevInteraction.y - interactionCurrent.y
            dx = prevInteraction.x - interactionCurrent.x
            if (Math.abs(dy) > Math.abs(dx))
              $window.scrollBy(0, dy)
              prevInteraction.y += dy
              interactionCurrent.y += dy

          xCont = elementStartX + (interactionCurrent.x - interactionStart.x)
          doTransform()


      element.bind 'click', (event) ->
        event.preventDefault() if (!allowClick)
        allowClick


      run = ->
        setInterval (->
          changed = false

          if v
            v *= f
            xCont -= v
            v = 0 if Math.abs(v) < 0.001
            changed = true

          if allowClick && Math.abs(v) < 2
            snapTargetX = itemWidth * Math.round(xCont / itemWidth)
            if xCont != snapTargetX
              xCont += (snapTargetX-xCont)*spring
              changed = true

          if changed
            doTransform()
            rearrange()

        ), 20



      # endless loop rearrange
      rearrange = ->
        if lastItem.x + xCont > xMax + lastItem.clientWidth * 0.51
          lastItem.x = firstItem.x - lastItem.clientWidth
          positionItem lastItem
          [firstItem, lastItem] = [lastItem, lastItem.prevItem]
          rearrange()

        else if firstItem.x + xCont < xMin - firstItem.clientWidth * 0.51
          firstItem.x = lastItem.x + firstItem.clientWidth
          positionItem firstItem
          [firstItem, lastItem] = [firstItem.nextItem, firstItem]
          rearrange()


      positionItem = (item) ->
#        angular.element(item).css 'left', item.x + 'px'
        item.style.left = item.x + 'px'

#      oldn = 0
#      rearrange = ->
#        n = -Math.round(xOff/390)
#        if n == oldn
#          oldn = n
#          return
#        oldn = n
#
#        count = items.length
#        x = n*390
#        n = n%(count-1)
#
#        console.log "-->", n+1, count-1, 0, n
#        console.log "-->items", items[n..count]

#        indexes = [n+1..count-1].concat([0..n])
#        for idx in indexes
#          console.log "-->idx", idx
#          item = items[idx]
#          angular.element(item).css 'left', x + 'px'
#          x += item.clientWidth

      doTransform = ->
        if has3d
          contElm.css
            "-webkit-transform": 'translate3d(' + xCont + 'px, 0px, 0px)'
            "-moz-transform": 'translate3d(' + xCont + 'px, 0px, 0px)'
            "-o-transform": 'translate3d(' + xCont + 'px, 0px, 0px)'
            "-ms-transform": 'translate3d(' + xCont + 'px, 0px, 0px)'
            transform: 'translate3d(' + xCont + 'px, 0px,0px)'
        else
          contElm.css('left', xCont);


      calcContentWidth = ->
        # calculate contentWidth by checking widths of the children
        #chs = element.children().eq(0).children()
        contentWidth = 0
        lastidx = items.length-1
        firstItem = items[0]
        lastItem = items[lastidx]
        itemWidth = firstItem.clientWidth
        for item,i in items
          if item is lastItem then item.nextItem = firstItem else item.nextItem = items[i+1]
          if item is firstItem then item.prevItem = lastItem else item.prevItem = items[i-1]

          item.x = contentWidth
          positionItem(item)
          contentWidth += item.clientWidth

        xMax = contentWidth/2 + element.clientWidth/2
        xMin = element.clientWidth/2 - contentWidth/2


      onWinResize = ->
        calcContentWidth()
        rearrange()


      onWinResize()

      scope.wheel = (event, delta, deltaX, deltaY) ->
        if deltaX
          event.preventDefault()
          if deltaX > 0
            v = 1  if v < 1
            v = Math.min(maxv, (v + 2) * a)
          else
            v = -1  if v > -1
            v = Math.max(naxv, (v - 2) * a)


      # initialize
      run()
      winElm.on 'resize', onWinResize
  ] # /infiniteSlider
)()