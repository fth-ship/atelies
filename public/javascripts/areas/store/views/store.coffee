define [
  'jquery'
  'underscore'
  'backboneConfig'
  'handlebars'
  'showdown'
  './storeProducts'
  'text!./templates/store.html'
  './productsSearchResults'
], ($, _, Backbone, Handlebars, Showdown, ProductsView, storeTemplate, ProductsSearchResultsView) ->
  class StoreView extends Backbone.Open.View
    template: storeTemplate
    initialize: (opt) ->
      @store = opt.store
      @products = opt.products
      @user = opt.user
      @markdown = new Showdown.converter()
    render: ->
      @$el.empty()
      context = Handlebars.compile @template
      if @store.homePageDescription
        homePageDescription = @markdown.makeHtml @store.homePageDescription
      userOwned = @user?.isSeller and _.contains @user.stores, @store.slug
      @$el.html context store: @store, staticPath: @staticPath, homePageDescription: homePageDescription, userOwned: userOwned, evaluationAvgRating: @store.evaluationAvgRating, numberOfEvaluations: @store.numberOfEvaluations, hasEvaluations: @store.numberOfEvaluations > 0
      @$("#ratingStars").jRating
        bigStarsPath : "#{staticPath}/images/jrating/stars.png"
        smallStarsPath : "#{staticPath}/images/jrating/small.png"
        sendRequest: off
        rateMax: 5
        canRateAgain: on
        step: true
        showRateInfo: off
        isDisabled: on
      @productsView = new ProductsView products:@products
      @$('#productsPlaceHolder').html @productsView.el
      document.title = @store.name
      super
    showProductsSearchResults: (searchTerm, products) ->
      $('#productSearchTerm').val searchTerm
      productsSearchResultsView = new ProductsSearchResultsView products:products
      @$('#productsPlaceHolder').html productsSearchResultsView.el
      document.title = "#{@store.name} - busca por: #{searchTerm}"
