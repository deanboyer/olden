###

Copyright (c) 2014 ...

###

# Dependencies
Env = require './env'

Utils = {
  'transform':
    Modernizr.prefixed('transform').replace(/([A-Z])/g, (str,m1) =>
      return '-' + m1.toLowerCase()
    ).replace(/^ms-/,'-ms-')
  ,
  'translate': (x, y) =>
    tran = if Modernizr.csstransforms3d then 'translate3d' else 'translate'
    vals = if Modernizr.csstransforms3d then '(' + x + ', ' + y + ', 0)' else '(' + x + ', ' + y + ')'
    return tran + vals
  ,
  'transition_end':
    (=>
      transEndEventNames = {
        'WebkitTransition' : 'webkitTransitionEnd',
        'MozTransition'    : 'transitionend',
        'OTransition'      : 'oTransitionEnd otransitionend',
        'msTransition'     : 'MSTransitionEnd',
        'transition'       : 'transitionend'
      }

      return transEndEventNames[Modernizr.prefixed('transition')]
    )()
  ,
  'is_mobile':
    {
      'any': ->
        return (
          (/Android/i).test(navigator.userAgent) or
          (/BlackBerry/i).test(navigator.userAgent) or
          (/iPhone|iPad|iPod/i).test(navigator.userAgent) or
          (/Opera Mini/i).test(navigator.userAgent) or
          (/IEMobile/i).test(navigator.userAgent)
        )
    }
}

# Carousel
CarouselComponent = require './components/carousel-component'

class Application

  ###
  *------------------------------------------*
  | constructor:void (-)
  |
  | Construct.
  *----------------------------------------###
  constructor: ->
    # Globals
    Olden.utils = Utils
    Olden.$win = $(window)
    Olden.$doc = $(document)
    Olden.$htmlbod = $('html,body')

    @$coll = $('.collection')
    @$abt = $('#about-btn')
    @$closeBtn = $('#close-btn')
    @$findUs = $('#locations-btn')
    @$backup = $('#back-top')
    @active_carousel = null

    @build()

  ###
  *------------------------------------------*
  | build:void (-)
  |
  | Build.
  *----------------------------------------###
  build: ->

    # Carousel
    @ladies_carousel_c = new CarouselComponent({'$el': $('#ladies-carousel')});
    @mens_carousel_c = new CarouselComponent({'$el': $('#mens-carousel')});

    @slideEvent()
    @scrollEvent()
    @sliderEvents()
    @closeSlider()

    setTimeout (->
      $('#loader').css 'top', '-100%'
    ), 666

  ###
  *------------------------------------------*
  | sliderEvents:void (-)
  |
  | Fire off the slider.
  *----------------------------------------###
  sliderEvents: =>
    @$coll.on 'click', (e) =>
      $(@).removeClass('fire-it-off')
      $(e.currentTarget).addClass('fire-it-off')

      # Clean this up
      setTimeout (->
        $('#mens-con:not(.fire-it-off)').css 'left', '100%'
        $('#ladies-con:not(.fire-it-off)').css 'left', '-50%'

        $('#olden-flag').css
          'top': '0',
          'transform': 'translate(-50%, 0%) scale(0.5,0.5)',
          'transform': 'translate3d(-50%, 0%, 0) scale(0.5,0.5)'

      ), 333

      setTimeout (=>
        # ACTIVATE CAROUSEL
        if $(e.currentTarget).attr('id') is 'ladies-con'
          @active_carousel = 'ladies'
          @ladies_carousel_c.activate()
        else
          @active_carousel = 'mens'
          @mens_carousel_c.activate()

        $('#collection-slider').addClass('inView')
      ), 666

  ###
  *------------------------------------------*
  | closeSlider:void (-)
  |
  | Close the slider.
  *----------------------------------------###
  closeSlider: =>
    @$closeBtn.on 'click', () =>
      $('.collection').removeClass('fire-it-off')
      $('#collection-slider').removeClass('inView')

      # SUSPEND CAROUSEL
      if @active_carousel is 'ladies'
        @ladies_carousel_c.suspend()
      else
        @mens_carousel_c.suspend()

      setTimeout (->
        $('#mens-con').css 'left', '50%'
        $('#ladies-con').css 'left', '0%'
      ), 333

  ###
  *------------------------------------------*
  | slideEvent:void (-)
  |
  | Slide down to the gallery.
  *----------------------------------------###
  slideEvent: =>

    @$abt.on 'click', () =>
      $("#about").addClass('active').show()
      @slideToAbout()

    @$findUs.on 'click', () =>
      @slideToLocation()

  ###
  *------------------------------------------*
  | scrollEvent:void (-)
  |
  | Slide down to the gallery.
  *----------------------------------------###
  scrollEvent: =>
    $(window).on 'scroll', () ->
      if window.pageYOffset > 100 && $(window).width() > 1024
        setTimeout (->
          $('#olden-flag').css
            'top': '0',
            'transform': 'translate(-50%, 0%) scale(0.5,0.5)'
        ),200

  ###
  *------------------------------------------*
  | slideToAbout:void (-)
  |
  | Slide down to the gallery.
  *----------------------------------------###
  slideToAbout: =>
    Olden.$htmlbod.animate {
      scrollTop: $("#about").offset().top
    }, 666, 'easeInOutExpo'

    if $(window).width() > 1024
      setTimeout (->
        $('#olden-flag').css
          'top': '0',
          'transform': 'translate(-50%, 0%) scale(0.5,0.5)'
      ),200


  ###
  *------------------------------------------*
  | slideToLocation:void (-)
  |
  | Slide down to the gallery.
  *----------------------------------------###
  slideToLocation: =>
    Olden.$htmlbod.animate {
      scrollTop: $("#locations").offset().top
    }, 666, 'easeInOutExpo'

    if $(window).width() > 1024
      setTimeout (->
        $('#olden-flag').css
          'top': '0',
          'transform': 'translate(-50%, 0%) scale(0.5,0.5)'
      ),200

  ###
  *------------------------------------------*
  | flagAction:void (-)
  |
  | Slide down to the gallery.
  *----------------------------------------###
  flagAction: =>
    $('#olden-flag').css
      'top': '0',
      'transform': 'translate(-50%, 0%) scale(0.5,0.5)',
      'transform': 'translate3d(-50%, 0%, 0) scale(0.5,0.5)'

module.exports = Application

$ ->
  # instance
  Olden.instance = new Application()