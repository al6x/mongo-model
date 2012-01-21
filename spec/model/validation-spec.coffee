require '../helper'

describe "Model Validation", ->
  withMongo()

  describe 'CRUD', ->
    [Unit, Item, unit, item] = [null, null, null, null]
    beforeEach ->
      class Tmp.Unit extends Model
        @collection 'units'
        @embedded 'items'
      Unit = Tmp.Unit

      class Tmp.Item extends Model
      Item = Tmp.Item

      unit = new Unit()
      item = new Item()
      unit.items = [item]

    it.sync 'should not save, update or delete invalid objects', ->
      # Create.
      unit.valid = (args..., callback) -> callback null, false
      unit.save().should be: false

      unit.valid = (args..., callback) -> callback null, true
      unit.save().should be: true

      # Update.
      unit.valid = (args..., callback) -> callback null, false
      unit.save().should be: false

      unit.valid = (args..., callback) -> callback null, true
      unit.save().should be: true

      # Delete.
      unit.valid = (args..., callback) -> callback null, false
      unit.delete().should be: false

      unit.valid = (args..., callback) -> callback null, true
      unit.delete().should be: true

    it.sync 'should not save, update or delete invalid embedded objects', ->
      # Create.
      item.valid = (args..., callback) -> callback null, false
      unit.save().should be: false

      item.valid = (args..., callback) -> callback null, true
      unit.save().should be: true

      # Update.
      item.valid = (args..., callback) -> callback null, false
      unit.save().should be: false

      item.valid = (args..., callback) -> callback null, true
      unit.save().should be: true

      # Delete.
      item.valid = (args..., callback) -> callback null, false
      unit.delete().should be: false

      item.valid = (args..., callback) -> callback null, true
      unit.delete().should be: true

    it.sync "should be able to skip validation", ->
      unit.valid = (args..., callback) -> callback null, false
      unit.save(validate: false).should be: true

      unit.valid = (args..., callback) -> callback null, true
      item.valid = (args..., callback) -> callback null, false
      unit.save(validate: false).should be: true


  describe "Callbacks", ->
    Unit = null
    beforeEach ->
      class Tmp.Unit extends Model
        @collection 'units'
      Unit = Tmp.Unit

    it.sync "should support validation callbacks", ->
      Unit.validate (callback) ->
        @errors().add 'name', 'is invalid' unless /^[a-z]+$/i.test @name
        callback null

      unit = new Unit(name: '43')
      unit.valid().should be: false
      unit.errors().should be: {name: ['is invalid']}

      unit = new Unit(name: 'Zeratul')
      unit.valid().should be: true
      unit.errors().should be: {}

    it.sync "should not save model with errors", ->
      Unit.validate (callback) ->
        @errors().add 'name', 'is invalid' unless /^[a-z]+$/i.test @name
        callback null

      unit = new Unit(name: '43')
      unit.valid().should be: false
      unit.errors().should be: {name: ['is invalid']}

      unit = new Unit(name: 'Zeratul')
      unit.valid().should be: true
      unit.errors().should be: {}

    it.sync "should clear errors before validation", ->
      Unit.validate (callback) ->
        @errors().add 'name', 'is invalid' unless /^[a-z]+$/i.test @name
        callback null

      unit = new Unit(name: '43')
      unit.valid().should be: false
      unit.name = 'Zeratul'
      unit.valid().should be: true

  describe "Special Database Exceptions", ->
    Unit = null
    beforeEach ->
      class Tmp.Unit extends Model
        @collection 'units'
      Unit = Tmp.Unit

    it.sync "should convert unique index exception to errors", ->
      units = $db.collection 'units'
      units.ensureIndex {name: 1}, unique: true

      Unit.create name: 'Zeratul'

      unit = new Unit name: 'Zeratul'
      unit.save().should be: false
      unit.errors().should be: {base: ["not unique value"]}