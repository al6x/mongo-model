require '../helper'

describe "Model CRUD", ->
  withMongo()

  describe "Main Object", ->
    [Unit, unit] = [null, null]
    beforeEach ->
      class Tmp.Unit extends Model
        @collection 'units'

      Unit = Tmp.Unit
      unit = new Unit(name: 'Zeratul', info: 'Dark Templar')

    itSync "should allow to read object as hash, without unmarshalling", ->
      units = $db.collection 'units'
      units.save unit
      units.first({}, object: false).should.eql unit.toHash()