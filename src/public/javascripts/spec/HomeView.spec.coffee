product1 = { _id: '1', productName: 'prod 1', picture: 'http://a.jpg', price: 3.43, storeName: 'store 1', storeSlug: 'store_1' }
product2 = { _id: '2', productName: 'prod 2', picture: 'http://b.jpg', price: 7.78, storeName: 'store 2', storeSlug: 'store_2' }
products = [ product1, product2 ]
define 'productsHomeData', -> products
define [
  'jquery'
  'views/Home'
], ($, HomeView) ->
  homeView = null
  el = $('<div></div>')
  describe 'HomeView', ->
    beforeEach ->
      homeView = new HomeView el:el
      homeView.render()
    it 'should render the products', ->
      expect($('#productsHome', el)).toBeDefined()
    it 'should display all the products', ->
      expect($('#productsHome>tbody>tr', el).length).toBe products.length
    it 'should display the store name for product 1', ->
      expect($("#1_storeName", el).text()).toBe product1.storeName
    it 'should display the store slug for product 1', ->
      expect($("#1_storeSlug", el).text()).toBe product1.storeSlug
    it 'should display the store name for product 2', ->
      expect($("#2_storeName", el).text()).toBe product2.storeName
    it 'should display the store slug for product 2', ->
      expect($("#2_storeSlug", el).text()).toBe product2.storeSlug