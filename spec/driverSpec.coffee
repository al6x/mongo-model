require './helper'
mongo = require '../lib/driver'
_     = require 'underscore'

describe "Database", ->
  withMongo()

  it "should provide handy shortcuts for collections", ->
    expect(@db.collection('test').name).to.eql 'test'

  itSync "should list collection names", (done) ->
    @db.collection('alpha').create a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'

  itSync "should clear", ->
    @db.collection('alpha').insert a: 'b'
    expect(@db.collectionNames()).to.contain 'alpha'
    @db.clear()
    expect(@db.collectionNames()).not.to.contain 'alpha'

describe "Collection", ->
  withMongo()

  describe "CRUD", ->
    itSync "should create", ->
      units = @db.collection 'units'
      unit = name: 'Probe',  status: 'alive'
      expect(units.create(unit)).not.to.be undefined
      expect(unit.id).to.be.a 'string'
      expect(units.first(name: 'Probe').status).to.eql 'alive'

    itSync "should update", ->
      units = @db.collection 'units'
      unit = name: 'Probe',  status: 'alive'
      units.create unit
      expect(units.first(name: 'Probe').status).to.be 'alive'
      unit.status = 'dead'
      units.update {id: unit.id}, unit
      expect(units.first(name: 'Probe').status).to.be 'dead'
      expect(units.count()).to.be 1

    itSync "should update in-place", ->
      units = @db.collection 'units'
      units.create name: 'Probe',  status: 'alive'
      expect(units.update({name: 'Probe'}, $set: {status: 'dead'})).to.be 1
      expect(units.first(name: 'Probe').status).to.be 'dead'

    itSync "should delete", ->
      units = @db.collection 'units'
      units.create name: 'Probe',  status: 'alive'
      expect(units.delete(name: 'Probe')).to.be 1
      expect(units.count(name: 'Probe')).to.be 0

    itSync "should update all matched by criteria (not just first as default in mongo)", ->
      units = @db.collection 'units'
      units.save name: 'Probe',  race: 'Protoss', status: 'alive'
      units.save name: 'Zealot', race: 'Protoss', status: 'alive'
      units.update {race: 'Protoss'}, $set: {status: 'dead'}
      expect(units.all().map((u) -> u.status)).to.eql ['dead', 'dead']
      units.delete race: 'Protoss'
      expect(units.count()).to.be 0

    itSync "should use short string id (instead of BSON::ObjectId as default in mongo)", ->
      units = @db.collection 'units'
      unit = name: 'Probe',  status: 'alive'
      units.create unit
      expect(unit.id).to.be.a 'string'

  describe "Querying", ->
    itSync "should return first element", ->
      units = @db.collection 'units'
      expect(units.first()).to.be null
      units.save name: 'Zeratul'
      expect(units.first(name: 'Zeratul').name).to.be 'Zeratul'

    itSync 'should return all elements', ->
      units = @db.collection 'units'
      expect(units.all()).to.eql []
      units.save name: 'Zeratul'
      list = units.all(name: 'Zeratul')
      expect(list).to.have.length 1
      expect(list[0].name).to.be 'Zeratul'

    itSync 'should return count of elements', ->
      units = @db.collection 'units'
      expect(units.count(name: 'Zeratul')).to.be 0
      units.save name: 'Zeratul'
      units.save name: 'Tassadar'
      expect(units.count(name: 'Zeratul')).to.be 1

    itSync "should delete via cursor", ->
      units = @db.collection 'units'
      units.create name: 'Probe',  status: 'alive'
      units.find(name: 'Probe').delete()
      expect(units.count(name: 'Probe')).to.be 0

describe "Configuration", ->
  withMongo()

  oldOptions = null
  beforeEach -> oldOptions = _(mongo.options).clone()
  afterEach  -> mongo.options = oldOptions

  itSync "should use config and get databases by alias", ->
    config =
      databases:
        mytest:
          name: 'test'
    mongo.configure config

    try
      db = mongo._db('mytest')
      expect(db.name).to.be 'test'
    finally
      db.close() if db

describe "Integration with Model", ->
  withMongo()

  # itSync "should save models", ->
  #   model =
  #     toHtml: -> {name: 'Probe'}
  #     setId: (id) -> @id = id
  #     getId: -> @id
  #
  #   units = @db.collection 'units'
  #   units.save model
  #   expect(model.id).to.be.a 'string'
  #   expect(units.first(name: 'Probe')).to.be 0