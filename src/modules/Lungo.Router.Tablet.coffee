###
Handles the <sections> and <articles> to show

@namespace Lungo
@class Router

@author Javier Jimenez Villar <javi@tapquo.com> || @soyjavi
@author Guillermo Pascual <pasku@tapquo.com> || @pasku1
@author Ignacio Olalde <ina@tapquo.com> || @piniphone
###


Lungo.RouterTablet = do (lng = Lungo) ->

  C                   = lng.Constants
  HASHTAG             = "#"
  _history            = []
  _animating          = false

  ###
  Navigate to a <section>.
  @method   section
  @param    {string} Id of the <section>
  ###
  section = (section_id) ->
    return false if _animating
    current = lng.Element.Cache.section
    if _notCurrentTarget current, section_id
      query = C.ELEMENT.SECTION + HASHTAG + section_id
      future = if current then current.siblings(query) else lng.dom(query)
      if future.length
        _show future, current
        step section_id
        do _url unless Lungo.Config.history is false
        do _updateNavigationElements
    # else do lng.Aside.hide

  ###
  Return to previous section.
  @method   back
  ###
  back = (animating = true) ->
    return false if _animating
    do _removeLast
    current = lng.Element.Cache.section
    query = C.ELEMENT.SECTION + HASHTAG + history()
    future = current.siblings(query)
    if future.length
      _show future, current, true, animating
      do _url unless Lungo.Config.history is false
      do _updateNavigationElements

  ###
  Displays the <article> in a particular <section>.
  @method   article
  @param    {string} <section> Id
  @param    {string} <article> Id
  ###
  article = (section_id, article_id, element) ->
    if not _sameSection() then back false
    target = lng.dom "article##{article_id}"
    if target.length > 0
      section = target.closest C.ELEMENT.SECTION
      lng.Router.section(section.attr("id"))
      section.children("#{C.ELEMENT.ARTICLE}.#{C.CLASS.ACTIVE}").removeClass(C.CLASS.ACTIVE).trigger C.TRIGGER.UNLOAD
      target.addClass(C.CLASS.ACTIVE).trigger(C.TRIGGER.LOAD)
      # lng.Element.Cache.article.removeClass(C.CLASS.ACTIVE).trigger C.TRIGGER.UNLOAD
      # lng.Element.Cache.article = target.addClass(C.CLASS.ACTIVE).trigger(C.TRIGGER.LOAD)

      if element?.data(C.ATTRIBUTE.TITLE)?
        # lng.Element.Cache.section.find(C.QUERY.TITLE).text element.data(C.ATTRIBUTE.TITLE)
        section.find(C.QUERY.TITLE).text element.data(C.ATTRIBUTE.TITLE)
      do _url unless Lungo.Config.history is false
      _updateNavigationElements article_id

  ###
  Triggered when <section> animation ends. Reset animation classes of section and aside
  @method   animationEnd
  @param    {eventObject}
  ###
  animationEnd = (event) ->
    section = lng.dom(event.target)
    direction = section.data(C.ATTRIBUTE.DIRECTION)
    if direction
      section.removeClass C.CLASS.SHOW if direction is "out" or direction is "back-out"
      section.removeAttr "data-#{C.ATTRIBUTE.DIRECTION}"
    if section.hasClass("asideHidding")
      section.removeClass("asideHidding").removeClass("aside")
    if section.hasClass("asideShowing")
      section.removeClass("asideShowing").addClass("aside")
    if section.hasClass("shadowing")
      section.removeClass("shadowing").addClass("shadow")
    if section.hasClass("unshadowing")
      section.removeClass("unshadowing").removeClass("shadow")

    _animating = false

  ###
  Create a new element to the browsing history based on the current section id.
  @method step
  @param  {string} Id of the section
  ###
  step = (section_id) -> _history.push section_id if section_id isnt history()

  ###
  Returns the current browsing history section id.
  @method history
  @return {string} Current section id
  ###
  history = -> _history[_history.length - 1]

  ###
  Private methods
  ###
  _show = (future, current, backward, animating = true) ->
    if not backward and not _sameSection() then back false
    if current?
      if backward
        if animating then current.data(C.ATTRIBUTE.DIRECTION, "back-out")
        else current.removeClass("show")
      else
        future.addClass(C.CLASS.SHOW)
        future.data(C.ATTRIBUTE.DIRECTION, "in") if future.data(C.TRANSITION.ATTR)

    lng.Section.show current, future
    do _checkSectionAside if animating


  _checkSectionAside = (section) ->
    aside_id = lng.Element.Cache.section?.data("aside")
    is_other_aside = aside_id isnt lng.Element.Cache.aside?.attr("id")
    lng.Aside.hide (-> lng.Aside.show aside_id)


  _sameSection = ->
    if not event or not lng.Element.Cache.section then return true
    dispacher_section = lng.dom(event.target).closest("section,aside")
    same = dispacher_section.attr("id") is lng.Element.Cache.section.attr("id")
    return same

  _notCurrentTarget = (current, id) -> current?.attr(C.ATTRIBUTE.ID) isnt id

  _url = ->
    _hashed_url = ""
    _hashed_url += "#{section}/" for section in _history
    _hashed_url += lng.Element.Cache.article.attr "id"
    setTimeout (-> window.location.hash = _hashed_url), 0

  _updateNavigationElements = (article_id) ->
    article_id = lng.Element.Cache.article.attr(C.ATTRIBUTE.ID) unless article_id
    # Active visual signal for elements
    links = lng.dom(C.QUERY.ARTICLE_ROUTER).removeClass(C.CLASS.ACTIVE)
    links.filter("[data-view-article=#{article_id}]").addClass(C.CLASS.ACTIVE)
    # Hide/Show elements in current article
    nav = lng.Element.Cache.section.find(C.QUERY.ARTICLE_REFERENCE).addClass C.CLASS.HIDE
    nav.filter("[data-article~='#{article_id}']").removeClass C.CLASS.HIDE

  _removeLast = ->
    if _history.length > 1
      _history.length -= 1


  section : section
  back    : back
  article : article
  history : history
  step    : step
  animationEnd : animationEnd


