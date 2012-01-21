require '../helper'

describe "Model Querying", ->
  withMongo()

  Unit = null
  beforeEach ->
    class Tmp.Unit extends Model
      @collection 'units'
    Unit = Tmp.Unit

  describe "Scope", ->
    it "should allow to define scope", ->
      Unit.alive = -> @find status: 'alive'
      cursor = Unit.alive()
      cursor.selector.should be: {status: 'alive'}

      cursor = Unit.alive().find(race: 'Protoss')
      cursor.selector.should be: {status: 'alive', race: 'Protoss'}

    # Discarded.
    # it 'should allow to chain scopes', ->
    #   Unit.alive = -> @find status: 'alive'
    #   Unit.protosses = -> @find race: 'Protoss'
    #   cursor = Unit.alive().protosses()
    #   cursor.selector.should be: {status: 'alive', race: 'Protoss'}

  describe "Helpers", ->
    # Discarded.
    # it "should understand simplified form of sort", ->
    #   cursor = Unit.sort 'name'
    #   cursor.options.should be: {sort: [['name', 1]]}
    #
    #   cursor = Unit.sort 'race', 'name'
    #   cursor.options.should be: {sort: [['race', 1], ['name', 1]]}

    it 'should provide paginate', ->
      cursor = Unit.paginate 4, 10
      cursor.options.should be: {skip: 30, limit: 10}

    it "should provide limit, skip and sort", ->
      cursor = Unit.skip(30).limit(10).sort(name: 1).snapshot().find(race: 'Protoss')
      cursor.selector.should be: {race: 'Protoss'}
      cursor.options.should be: {skip: 30, limit: 10, sort: {name: 1}, snapshot: true}

  describe "Query", ->
    unit = null
    beforeEach ->
      unit = Unit.build name: 'Zeratul'

    it.sync 'should return first and all', ->
      _(Unit.first()).should be: null
      Unit.all().should be: []
      unit.save()
      Unit.first().shouldNot be: null
      list = Unit.all()
      list.length.should be: 1
      list[0].toHash().should be: unit.toHash()

    it.sync 'should be integrated with build, create and create!', ->
      u = Unit.find(name: 'Zeratul').build age: 500
      [u.name, u.age].should be: ['Zeratul', 500]

      Unit.find(name: 'Zeratul').create age: 500
      u = Unit.first()
      [u.name, u.age].should be: ['Zeratul', 500]

    it.sync 'should check existence', ->
      Unit.exists(name: 'Zeratul').should be: false
      unit.exists().should be: false
      unit.save()
      Unit.exists(name: 'Zeratul').should be: true
      unit.exists().should be: true