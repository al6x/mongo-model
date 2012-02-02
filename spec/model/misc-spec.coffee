require '../helper'

describe "Model Miscellaneous", ->
  withMongo()

  Unit = null
  beforeEach ->
    class Tmp.Unit extends Model
      @collection 'units'
    Unit = Tmp.Unit

  it 'should have cache', ->
    u = new Unit()
    u.cache().should.eql {}

  itSync "should create timestamps", ->
    Unit.timestamps()

    unit = Unit.build name: 'Zeratul'
    unit.save()

    unit = Unit.first()
    _(unit.createdAt).should.exist
    _(unit.updatedAt).should.exist

  describe 'Original', ->
    itSync "should provide original", ->
      unit = new Unit name: 'Zeratul'
      _(unit._original()).should.not.exist
      unit.save()
      unit.name = 'Tassadar'
      unit._original().name.should.eql 'Zeratul'

      unit.save()
      unit._original().name.should.eql 'Tassadar'

      unit = Unit.first()
      unit.name = 'Fenix'
      unit._original().name.should.eql 'Tassadar'

    # # Discarded.
    # itSync "should use identity map if provided", ->
    #   unit = new Unit name: 'Zeratul'
    #   _(unit._original()).should be: null
    #   unit.save()
    #
    #   _(Unit.identityMap()).size().should be: 0
    #   unit = Unit.first()
    #   _(Unit.identityMap()).size().should be: 1
    #
    #   unit.name = 'Tassadar'
    #
    #   unit._original().name.should be: 'Zeratul'