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
      cursor.selector.should.eql {status: 'alive'}

      cursor = Unit.alive().find(race: 'Protoss')
      cursor.selector.should.eql {status: 'alive', race: 'Protoss'}

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
      cursor.options.should.eql {skip: 30, limit: 10}

    it "should provide limit, skip and sort", ->
      cursor = Unit.skip(30).limit(10).sort(name: 1).snapshot().find(race: 'Protoss')
      cursor.selector.should.eql {race: 'Protoss'}
      cursor.options.should.eql {skip: 30, limit: 10, sort: {name: 1}, snapshot: true}

  describe "Query", ->
    unit = null
    beforeEach ->
      unit = Unit.build name: 'Zeratul'

    itSync 'should return first and all', ->
      _(Unit.first()).should.not.exist
      Unit.all().should.eql []
      unit.save()
      _(Unit.first()).should.exist
      list = Unit.all()
      list.length.should.eql 1
      list[0].toHash().should.eql unit.toHash()

    itSync 'should be integrated with build, create and create!', ->
      u = Unit.find(name: 'Zeratul').build age: 500
      [u.name, u.age].should.eql ['Zeratul', 500]

      Unit.find(name: 'Zeratul').create age: 500
      u = Unit.first()
      [u.name, u.age].should.eql ['Zeratul', 500]

    itSync 'should check existence', ->
      Unit.exists(name: 'Zeratul').should.be.false
      unit.exists().should.be.false
      unit.save()
      Unit.exists(name: 'Zeratul').should.be.true
      unit.exists().should.be.true