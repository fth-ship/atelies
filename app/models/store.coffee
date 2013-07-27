mongoose = require 'mongoose'
Product  = require './product'
slug     = require '../helpers/slug'
_        = require 'underscore'

storeSchema = new mongoose.Schema
  name:                   type: String, required: true
  nameKeywords:           [String]
  slug:                   String
  email:                  String
  description:            String
  homePageDescription:    String
  homePageImage:          String
  urlFacebook:            String
  urlTwitter:             String
  phoneNumber:            String
  city:                   type: String, required: true
  state:                  type: String, required: true
  zip:                    type: String, required: true
  otherUrl:               String
  banner:                 String
  flyer:                  String
  autoCalculateShipping:  Boolean
  pmtGateways:
    pagseguro:
      email:              String
      token:              String
  random:                 type: Number, required: true, default: Math.random()

storeSchema.methods.createProduct = ->
  product = new Product()
  product.storeName = @name
  product.storeSlug = @slug
  product

storeSchema.methods.toSimple = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    email: @email
    description: @description
    homePageDescription: @homePageDescription
    homePageImage: @homePageImage
    urlFacebook: @urlFacebook
    urlTwitter: @urlTwitter
    phoneNumber: @phoneNumber
    city: @city
    state: @state
    zip: @zip
    otherUrl: @otherUrl
    banner: @banner
    flyer: @flyer
    autoCalculateShipping: @autoCalculateShipping
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.toSimpler = ->
  store =
    _id: @_id
    name: @name
    slug: @slug
    homePageImage: @homePageImage
    flyer: @flyer
  store.pagseguro = @pagseguro()
  store
storeSchema.methods.pagseguro = -> @pmtGateways.pagseguro?.token? and @pmtGateways.pagseguro?.email?
storeSchema.path('name').set (val) ->
  @nameKeywords = if val is '' then [] else val.toLowerCase().split ' '
  @slug = slug val.toLowerCase(), "_"
  val
storeSchema.methods.setAutoCalculateShipping = (val, cb) ->
  unless val
    @autoCalculateShipping = false
    setImmediate => cb null, true
    return
  Product.findByStoreSlug @slug, (err, products) =>
    return cb err if err?
    productWithMissingInfo = _.find products, (p) -> p.hasShippingInfo() is false
    @autoCalculateShipping = true unless productWithMissingInfo?
    cb null, not productWithMissingInfo?
storeSchema.methods.setPagseguro = (set) ->
  if typeof set is 'boolean' and set is false
    @pmtGateways.pagseguro = undefined
  else
    @pmtGateways.pagseguro = set
storeSchema.methods.updateFromSimple = (simple) ->
  for attr in ['name', 'email', 'description', 'homePageDescription', 'urlFacebook', 'urlTwitter', 'phoneNumber', 'city', 'state', 'zip', 'otherUrl' ]
    if simple[attr]? and simple[attr] isnt ''
      @[attr] = simple[attr]
    else
      @[attr] = undefined

Store = mongoose.model 'store', storeSchema
Store.nameExists = (name, cb) ->
  aSlug = slug name.toLowerCase(), "_"
  Store.findBySlug aSlug, (err, store) -> cb err, store?
Store.findBySlug = (slug, cb) -> Store.findOne slug: slug, cb
Store.findWithProductsBySlug = (slug, cb) ->
  Store.findBySlug slug, (err, store) ->
    return cb err if err?
    return cb(null, null) if store is null
    Product.findByStoreSlug slug, (err, products) ->
      return cb err if err?
      cb null, store, products
Store.findWithProductsById = (_id, cb) ->
  Store.findById _id, (err, store) ->
    return cb err if err?
    return cb(null, null) if store is null
    Product.findByStoreSlug store.slug, (err, products) ->
      return cb err if err?
      cb null, store, products
Store.findRandomForHome = (howMany, cb) ->
  random = Math.random()
  Store.find({flyer: /./, random:$gte:random}).sort('random').limit(howMany).exec (err, stores) ->
    return cb err if err?
    if stores.length > howMany / 2
      cb null, stores
    else
      Store.find({flyer: /./, random:$lte:random}).sort('random').limit(howMany).exec (err, stores) ->
        return cb err if err?
        if stores.length > howMany / 2
          cb null, stores
        else
          Store.find({flyer: /./}).sort('random').limit(howMany).exec cb

Store.searchByName = (searchTerm, cb) ->
  Store.find nameKeywords:searchTerm.toLowerCase(), (err, stores) ->
    return cb err if err?
    cb null, stores
Store.homePageImageDimension = '600x400'
Store.flyerDimension = '350x350'
#Store.bannerDimension = '1200x300'

module.exports = Store
