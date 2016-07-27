class CarouselComponent

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | init:object - init object
  |
  | Construct.
  *----------------------------------------###
  constructor: (init) ->
    @$el = init.$el

    @build()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | Build.
  *----------------------------------------###
  build: ->
    # Cache selectors
    @$slider = $('.carousel-slider', @$el)
    @$slide = $('.carousel-slider li', @$el)
    @total_slides = @$slide.length

    # Draggable vars
    @dragging = false
    @y_axis = false
    @drag_time = 666
    @active_index = 0
    @start_time = 0
    @trans_x = 0
    @start_x = 0
    @current_x = 0
    @start_y = 0
    @current_y = 0
    @range = 30
    @current_range = 0
    @now = 0
    @swiped = false

  ###
  *------------------------------------------*
  | onTouchstart:void (=)
  |
  | Touch start.
  *----------------------------------------###
  onTouchstart: (e) =>
    if (e.which is 1 or Olden.utils.is_mobile.any())
      @dragging = true
      @slide_width = @$slide.eq(@active_index).outerWidth(true)
      @start_time = (new Date()).getTime()
      @start_x = if Olden.utils.is_mobile.any() then e.originalEvent.targetTouches[0].pageX else e.pageX
      @start_y = if Olden.utils.is_mobile.any() then e.originalEvent.targetTouches[0].pageY else e.pageY

      Olden.$doc
        .off('mouseup.carousel touchend.carousel')
        .one('mouseup.carousel touchend.carousel', @onTouchend)

  ###
  *------------------------------------------*
  | onTouchmove:void (=)
  |
  | Touch move.
  *----------------------------------------###
  onTouchmove: (e) =>
    if @dragging is true and @y_axis is false
      @current_x = if Olden.utils.is_mobile.any() then e.originalEvent.targetTouches[0].pageX else e.pageX
      @current_y = if Olden.utils.is_mobile.any() then e.originalEvent.targetTouches[0].pageY else e.pageY
      direction_x = @current_x - @start_x
      @current_range = if @start_x is 0 then 0 else Math.abs(direction_x)
      current_range_y = if @start_y is 0 then 0 else Math.abs(@current_y - @start_y)

      if @current_range < current_range_y
        @y_axis = true
      else
        @now = (new Date()).getTime()
        resistance = if (direction_x >= 0 and @active_index is 0) or (direction_x <= 0 and @active_index is (@total_slides - 1)) then 4 else 1
        drag_x = ((@trans_x / 100) * @slide_width + (direction_x / resistance))

        @$slider
          .addClass('no-trans')
          .css(Olden.utils.transform, Olden.utils.translate("#{drag_x}px", 0))

        return false

  ###
  *------------------------------------------*
  | onTouchend:void (=)
  |
  | Touch end.
  *----------------------------------------###
  onTouchend: =>
    if @$slider.hasClass('no-trans')
      @$slider.removeClass('no-trans')

      if @now - @start_time < @drag_time and @current_range > @range or @current_range > (@slide_width / 2)
        @swiped = true
        if @current_x > @start_x
          @previous()
        else
          @next()
      else
        @updateSlider()

    @dragging = false
    @y_axis = false
    @swiped = false
    return false

  ###
  *------------------------------------------*
  | previous:void (=)
  |
  | Previous slide.
  *----------------------------------------###
  previous: =>
    if @active_index isnt 0
      @active_index = @active_index - 1

    @updateSlider()

  ###
  *------------------------------------------*
  | next:void (=)
  |
  | Next slide.
  *----------------------------------------###
  next: =>
    if @active_index isnt (@total_slides - 1)
      @active_index = @active_index + 1

    @updateSlider()

  ###
  *------------------------------------------*
  | updateSlider:void (=)
  |
  | Update slider.
  *----------------------------------------###
  updateSlider: =>
    @trans_x = -(@active_index * 100)

    if @swiped is true
      @$slider.addClass('swiped')

    @$slider
      .css(Olden.utils.transform, Olden.utils.translate("#{@trans_x}%", 0))
      .off(Olden.utils.transition_end)
      .one(Olden.utils.transition_end, =>
        @$slider[0].offsetHeight
        @$slider.removeClass('no-trans swiped')
      )

  ###
  *------------------------------------------*
  | reset:void (=)
  |
  | Reset.
  *----------------------------------------###
  reset: =>
    @$slider
      .addClass('no-trans')
      .css(Olden.utils.transform, Olden.utils.translate('0%', 0))

    @$slider[0].offsetHeight
    @$slider.removeClass('no-trans')

    @trans_x = 0
    @active_index = 0
    @y_axis = false
    @swiped = false

  ###
  *------------------------------------------*
  | activate:void (-)
  |
  | Activate.
  *----------------------------------------###
  activate: ->
    @reset()
    @$el
      .addClass('active')
      .off('mousedown touchstart mousemove touchmove')
      .on('mousedown touchstart', @onTouchstart)
      .on('mousemove touchmove', @onTouchmove)

  ###
  *------------------------------------------*
  | suspend:void (-)
  |
  | Suspend.
  *----------------------------------------###
  suspend: ->
    @$el
      .removeClass('active')
      .off('mousedown touchstart mousemove touchmove')

module.exports = CarouselComponent