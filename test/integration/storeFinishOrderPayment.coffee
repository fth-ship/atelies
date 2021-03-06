require './support/_specHelper'
Product                         = require '../../app/models/product'
Order                           = require '../../app/models/order'
StoreFinishOrderPaymentPage     = require './support/pages/storeFinishOrderPaymentPage'
StoreFinishOrderShippingPage    = require './support/pages/storeFinishOrderShippingPage'
StoreCartPage                   = require './support/pages/storeCartPage'
StoreProductPage                = require './support/pages/storeProductPage'
_                               = require 'underscore'

describe 'Store Finish Order: Payment', ->
  page = storeFinishOrderShippingPage = storeCartPage = storeProductPage = store = product1 = product2 = product3 = store2 = user1 = p1Inventory = p2Inventory = null
  after (done) -> page.closeBrowser done
  before (done) =>
    page = new StoreFinishOrderPaymentPage
    storeFinishOrderShippingPage = new StoreFinishOrderShippingPage page
    storeCartPage = new StoreCartPage page
    storeProductPage = new StoreProductPage page
    whenServerLoaded done

  describe 'payment info', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.a()
        store.save()
        product1 = generator.product.a()
        product1.save()
        p1Inventory = product1.inventory
        product2 = generator.product.b()
        product2.save()
        p2Inventory = product2.inventory
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_1', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeCartPage.clickFinishOrder ->
                  storeFinishOrderShippingPage.clickSedexOption ->
                    storeFinishOrderShippingPage.clickContinue done
    it 'should show options for payment type with PagSeguro already selected', (done) ->
      page.paymentTypes (pts) ->
        pts.length.should.equal 2
        selectedPaymentType = _.findWhere pts, selected:true
        selectedPaymentType.value.should.equal 'pagseguro'
        done()
    it 'should be at payment page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}/finishOrder/payment"
        done()

  describe 'payment info for store without pagseguro enabled', ->
    before (done) ->
      cleanDB (error) ->
        return done error if error
        store = generator.store.c()
        store.save()
        product1 = generator.product.a()
        product1.storeSlug = store.slug
        product1.storeName = store.name
        product1.save()
        user1 = generator.user.d()
        user1.save()
        page.clearLocalStorage ->
          page.loginFor user1._id, ->
            storeProductPage.visit 'store_3', 'name_1', ->
              storeProductPage.purchaseItem ->
                storeCartPage.clickFinishOrder ->
                  storeFinishOrderShippingPage.clickSedexOption ->
                    storeFinishOrderShippingPage.clickContinue done
    it 'should show options for payment type with direct payment already selected', (done) ->
      page.paymentTypes (pts) ->
        pts.length.should.equal 1
        selectedPaymentType = _.findWhere pts, selected:true
        selectedPaymentType.value.should.equal 'directSell'
        done()
    it 'should be at payment page', (done) ->
      page.currentUrl (url) ->
        url.should.equal "http://localhost:8000/#{store.slug}/finishOrder/payment"
        done()
