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

    it.sync 'should perform CRUD with collection methods', ->
      # Read.
      units = $db.collection 'units'
      units.count().should be: 0
      units.all().should be: []
      _(units.first()).should be: null

      # Create.
      units.save(unit).should be: true
      unit._id.shouldNot be: null

      # Read.
      units.count().should be: 1
      obj = units.first()
      obj.toHash().should be: unit.toHash()
      obj.constructor.should be: unit.constructor

      # Update.
      unit.info = 'Killer of Cerebrates'
      units.save(unit).should be: true
      units.count().should be: 1
      units.first(name: 'Zeratul').info.should be: 'Killer of Cerebrates'

      # Delete.
      units.delete(unit).should be: true
      units.count().should be: 0

    it.sync 'should perform CRUD with model methods', ->
      # Read.
      Unit.count().should be: 0
      Unit.all().should be: []
      _(Unit.first()).should be: null

      # Create.
      unit.save().should be: true
      unit._id.shouldNot be: null

      # Read.
      Unit.count().should be: 1
      all = Unit.all()
      all.length.should be: 1
      all[0].toHash().should be: unit.toHash()
      Unit.first().toHash().should be: unit.toHash()

      # Update.
      unit.info = 'Killer of Cerebrates'
      unit.save().should be: true
      Unit.count().should be: 1
      Unit.first(name: 'Zeratul').info.should be: 'Killer of Cerebrates'

      # Delete.
      unit.delete().should be: true
      Unit.count().should be: 0

    it.sync 'should be able to save model to another collection', ->
      heroes = $db.collection 'heroes'
      unit.save collection: heroes
      heroes.first().toHash().should be: unit.toHash()

    it.sync 'should be able to save model to another collection defined as symbol', ->
      heroes = $db.collection 'heroes'
      unit.save collection: 'heroes'
      heroes.first().toHash().should be: unit.toHash()

    it.sync 'should update with modifiers', ->
      unit.save()

      Unit.update {_id: unit._id}, $set: {name: 'Tassadar'}
      unit.reload()
      unit.name.should be: 'Tassadar'

      unit.update $set: {name: 'Fenix'}
      unit.reload()
      unit.name.should be: 'Fenix'

    it.sync 'should build model', ->
      unit = Unit.build name: 'Zeratul'
      unit.name.should be: 'Zeratul'

    it.sync 'should create model', ->
      unit = Unit.create name: 'Zeratul'
      unit.toHash().should be: {name : 'Zeratul', _id : unit._id, _class : 'Unit'}
      Unit.first().name.should be: 'Zeratul'

    it.sync 'should delete all models', ->
      Unit.create name: 'Zeratul'
      Unit.count().should be: 1
      Unit.delete()
      Unit.count().should be: 0

    it.sync "should allow to read object as hash, without unmarshalling", ->
      units = $db.collection 'units'
      units.save unit
      units.first({}, object: false).should be: unit.toHash()

    it.sync 'should reload model', ->
      unit = Unit.create name: 'Zeratul'
      unit.name = 'Jim'
      unit.reload()
      unit.name.should == 'Zeratul'

  describe "Embedded Object", ->
    unit = null
    beforeEach ->
      class Tmp.Unit extends Model
        @embedded 'items'

      class Tmp.Item extends Model

      unit = new Tmp.Unit()
      unit.items = [
        new Tmp.Item(name: 'Psionic blade')
        new Tmp.Item(name: 'Plasma shield')
      ]

    it.sync 'should perform CRUD', ->
      # Create.
      units = $db.collection 'units'
      units.save unit
      unit._id.shouldNot be: null

      item = unit.items[0]
      _(item._id).should be: null

      # Read.
      units.count().should be: 1
      unit2 = units.first()
      unit2.toHash().should be: unit.toHash()

      item = unit.items[0]
      _(item._id).should be: null

      # Update.
      unit.items[0].name = 'Psionic blade level 3'
      item = new Tmp.Item name: 'Power suit'
      unit.items.push item
      units.save unit
      units.count().should be: 1
      unit2 = units.first()
      unit2.toHash().should be: unit.toHash()

      # Delete.
      units.delete unit
      units.count().should be: 0

    it.sync "should have :_parent reference to the main object", ->
      units = $db.collection 'units'
      units.save unit
      unit = units.first()
      _(unit._parent).should be: null
      unit.items[0]._parent.should be: unit

  it "should convert object to and from mongo-hash", ->
    class Tmp.Post extends Model
      @embedded 'tags', 'comments'

    class Tmp.Comment extends Model

    # Should aslo allow to use models that
    # are saved to array.
    # To do so we need to use toMongo and afterFromMongo.
    class Tmp.Tags extends Model
      constructor: -> @array = []
      push: (args...) -> @array.push args...
      toMongo: -> @array
    Tmp.Post.prototype.afterFromMongo = (doc) ->
      @tags = new Tmp.Tags
      @tags.array = doc.tags

    # Creating some data.
    comment = new Tmp.Comment()
    comment.text = 'Some text'

    tags = new Tmp.Tags()
    tags.push 'a', 'b'

    post = new Tmp.Post()
    post.title = 'Some title'
    post.comments = [comment]
    post.tags = tags

    hash = {
      _class   : 'Post',
      title    : 'Some title',
      comments : [{text: 'Some text', _class: 'Comment'}],
      tags     : ['a', 'b']
    }

    # Converting to mongo.
    post.toMongo().should be: hash

    [post._id, hash._id] = ['some id', 'some id']
    post.toMongo().should be: hash

    # Converting from mongo.
    Model._fromMongo(hash).toMongo().should be: hash