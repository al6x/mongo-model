require '../helper'

describe 'Model Callbacks', ->
  withMongo()

  describe "Basics", ->
    it.sync "should works in common case", ->
      messages = []

      class Tmp.Unit extends Model
        @embedded 'items'

        @before 'validate', (callback) ->
          messages.push 'before validate'
          callback()

        @after 'save', (callback) ->
          messages.push 'after save'
          callback()

      class Tmp.Item extends Model
        @before 'validate', (callback) ->
          messages.push 'embedded, before validate'
          callback()

        @after 'save', (callback) ->
          messages.push 'embedded, after save'
          callback()

      item = new Tmp.Item()
      unit = new Tmp.Unit()
      unit.items = [item]

      unit.save().should be: true
      messages.should be: [
        'before validate'
        'embedded, before validate'
        'after save'
        'embedded, after save'
      ]

  describe 'CRUD', ->
    [Unit, Item, unit, item, messages] = [null, null, null, null, null]
    beforeEach ->
      Unit = class Tmp.Unit extends Model
        @collection 'units'
        @embedded 'items'

      Item = class Tmp.Item extends Model

      item = new Tmp.Item()
      unit = new Tmp.Unit()
      unit.items = [item]

      messages = []
      unit.runCallbacks = (type, event, callback) ->
        messages.push "#{type} #{event}"
        callback null, true

      item.runCallbacks = (type, event, callback) ->
        messages.push "#{type} #{event} (child)"
        callback null, true

    it.sync 'should trigger create callbacks', ->
      unit.save().should be: true
      messages.should be: [
        'before save',
        'before save (child)',
        'before create',
        'before create (child)',
        'before validate',
        'before validate (child)',
        'after validate (child)',
        'after validate',
        'after create',
        'after create (child)',
        'after save',
        'after save (child)' ]

    it.sync 'should trigger update callbacks', ->
      unit.save().should be: true
      messages = []
      unit.save().should be: true
      messages.should be: [
        'before save',
        'before save (child)',
        'before update',
        'before update (child)',
        'before validate',
        'before validate (child)',
        'after validate (child)',
        'after validate',
        'after update',
        'after update (child)',
        'after save',
        'after save (child)' ]

    it.sync 'should trigger delete callbacks', ->
      unit.save().should be: true
      messages = []
      unit.delete().should be: true
      messages.should be: [
        'before delete',
        'before delete (child)',
        'before validate',
        'before validate (child)',
        'after validate (child)',
        'after validate',
        'after delete',
        'after delete (child)' ]

    it.sync 'should be able skip callbacks', ->
      unit.save(callbacks: false).should be: true
      unit.save(callbacks: false).should be: true
      unit.delete(callbacks: false).should be: true
      messages.should be: []

    it.sync 'should be able interrupt CRUD', ->
      delete unit.runCallbacks
      delete item.runCallbacks

      Unit.before 'create', (callback) ->
        callback null, false

      unit.save().should be: false
      Unit.count().should be: 0

    # # Discarded.
    # it.sync "should trigger after build callback after building the model", ->
    #   unit.save().should be: true
    #
    #   MainObject.after_instantiate do |instance|
    #     instance.should_receive(:after_build)
    #   end
    #   EmbeddedObject.after_instantiate do |instance|
    #     instance.should_not_receive(:after_build)
    #   end
    #   db.objects.first
    # end