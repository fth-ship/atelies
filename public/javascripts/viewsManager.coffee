define [
  './seoLoadManager'
  './social'
], (SEOLoadManager, Social) ->
  class ViewsManager
    @show: (view) ->
      @view.close() if @view?
      @view = view
      @$el.html view.el
      view.render ->
        new SEOLoadManager().done()
        Social.renderGooglePlus()
        Social.renderFacebook()
        Social.renderTwitter()
