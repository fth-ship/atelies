require './support/_specHelper'
Order                   = require '../../app/models/order'
Store                   = require '../../app/models/store'
StoreEvaluation         = require '../../app/models/storeEvaluation'
AccountOrderDetailPage  = require './support/pages/accountOrderDetailPage'
Postman                 = require '../../app/models/postman'

describe 'Account order detail page', ->
  page = store = product1 = product2 = user = order1 = userSeller = null
  before (done) =>
    page = new AccountOrderDetailPage()
    cleanDB (error) ->
      return done error if error
      store = generator.store.a()
      store.save()
      userSeller = generator.user.c()
      userSeller.stores.push store
      userSeller.save()
      product1 = generator.product.a()
      product1.save()
      product2 = generator.product.b()
      product2.save()
      user = generator.user.d()
      user.save()
      items = [
        { product: product1, quantity: 1 }
        { product: product2, quantity: 2 }
      ]
      shippingCost = 1
      Order.create user, store, items, shippingCost, 'directSell', (err, order) ->
        order1 = order
        order.orderDate = new Date(2013,0,1)
        order1.save()
        whenServerLoaded done

  describe 'show order with two products', ->
    before (done) =>
      page.loginFor user._id, ->
        page.visit order1._id, done
    it 'shows order', (done) ->
      page.order (order) ->
        order._id.should.equal order._id.toString()
        order.orderDate.should.equal '01/01/2013'
        order.storeName.should.equal store.name
        order.storeUrl.should.equal "http://localhost:8000/#{store.slug}"
        order.numberOfItems.should.equal order1.items.length
        order.shippingCost.should.equal 'R$ 1,00'
        order.totalProductsPrice.should.equal 'R$ 55,50'
        order.totalSaleAmount.should.equal 'R$ 56,50'
        order.deliveryAddress.street.should.equal user.deliveryAddress.street
        order.deliveryAddress.street2.should.equal user.deliveryAddress.street2
        order.deliveryAddress.city.should.equal user.deliveryAddress.city
        order.deliveryAddress.state.should.equal user.deliveryAddress.state
        order.deliveryAddress.zip.should.equal user.deliveryAddress.zip
        order.items.length.should.equal 2
        i1 = order.items[0]
        i2 = order.items[1]
        i1._id.should.equal product1._id.toString()
        i1.name.should.equal product1.name
        i1.price.should.equal 'R$ 11,10'
        i1.totalPrice.should.equal 'R$ 11,10'
        i1.picture.should.equal product1.picture
        i1.quantity.should.equal 1
        i1.url.should.equal "http://localhost:8000/#{product1.url()}"
        i2._id.should.equal product2._id.toString()
        i2.name.should.equal product2.name
        i2.price.should.equal 'R$ 22,20'
        i2.totalPrice.should.equal 'R$ 44,40'
        i2.picture.should.equal product2.picture
        i2.quantity.should.equal 2
        i2.url.should.equal "http://localhost:8000/#{product2.url()}"
        done()
    it 'shows pending evaluation', (done) ->
      page.newEvaluationVisible (itIs) ->
        itIs.should.be.true
        done()

  describe 'evaluation order and store', ->
    evaluationBody = rating = null
    before (done) =>
      Postman.sentMails.length = 0
      evaluationBody = "body1"
      rating = 4
      page.loginFor user._id, ->
        page.visit order1._id, ->
          page.evaluateOrderWith {body: evaluationBody, rating: rating}, done
    it 'should record the evaluation on the store', (done) ->
      Store.findById store._id, (err, st) ->
        st.numberOfEvaluations.should.equal 1
        st.evaluationAvgRating.should.equal 4
        done()
    it 'should have stored the evaluation and set it on the order', (done) ->
      StoreEvaluation.findOne order: order1._id, (err, ev) ->
        ev.body.should.equal evaluationBody
        ev.rating.should.equal rating
        ev.date.should.equalDate new Date()
        ev.store.toString().should.equal order1.store.toString()
        ev.order.toString().should.equal order1._id.toString()
        ev.user.toString().should.equal user._id.toString()
        Order.findById order1._id, (err, o) ->
          o.evaluation.toString().should.equal ev._id.toString()
          done()
    it 'should make the evaluation field disappear', (done) ->
      page.newEvaluationVisible (itIs) ->
        itIs.should.be.false
        done()
    it 'should show existing evaluation', (done) ->
      page.existingEvaluation (ev) ->
        ev.rating.should.equal rating
        done()
    it 'should send an e-mail message to the store admins', ->
      Postman.sentMails.length.should.equal 1
      mail = Postman.sentMails[0]
      mail.to.should.equal "#{userSeller.name} <#{userSeller.email}>"
      mail.subject.should.equal "Ateliês: A loja #{store.name} recebeu uma avaliação"
    it 'does not show pending evaluation anymore when visited again and shows existing evaluation', (done) ->
      page.reload ->
        page.newEvaluationVisible (itIs) ->
          itIs.should.be.false
          page.existingEvaluation (ev) ->
            ev.rating.should.equal rating
            done()
