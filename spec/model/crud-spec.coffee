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

    itSync 'should perform CRUD with collection methods', ->
      # Read.
      units = $db.collection 'units'
      units.count().should.eql 0
      units.all().should.eql []
      _(units.first()).should.not.exist

      # Create.
      units.save(unit).should.eql true
      _(unit._id).should.exist

      # Read.
      units.count().should.eql 1
      obj = units.first()
      obj.toHash().should.eql unit.toHash()
      obj.constructor.should.eql unit.constructor

      # Update.
      unit.info = 'Killer of Cerebrates'
      units.save(unit).should.be.true
      units.count().should.eql 1
      units.first(name: 'Zeratul').info.should.eql 'Killer of Cerebrates'

      # Delete.
      units.delete(unit).should.be.true
      units.count().should.eql 0

    itSync 'should perform CRUD with model methods', ->
      # Read.
      Unit.count().should.eql 0
      Unit.all().should.eql []
      _(Unit.first()).should.not.exist

      # Create.
      unit.save().should.be.true
      _(unit._id).should.exist

      # Read.
      Unit.count().should.eql 1
      all = Unit.all()
      all.length.should.eql 1
      all[0].toHash().should.eql unit.toHash()
      Unit.first().toHash().should.eql unit.toHash()

      # Update.
      unit.info = 'Killer of Cerebrates'
      unit.save().should.be.true
      Unit.count().should.eql 1
      Unit.first(name: 'Zeratul').info.should.eql 'Killer of Cerebrates'

      # Delete.
      unit.delete().should.be.true
      Unit.count().should.eql 0

    itSync 'should be able to save model to another collection', ->
      heroes = $db.collection 'heroes'
      unit.save collection: heroes
      heroes.first().toHash().should.eql unit.toHash()

    itSync 'should be able to save model to another collection defined as symbol', ->
      heroes = $db.collection 'heroes'
      unit.save collection: 'heroes'
      heroes.first().toHash().should.eql unit.toHash()

    itSync 'should update with modifiers', ->
      unit.save()

      Unit.update {_id: unit._id}, $set: {name: 'Tassadar'}
      unit.reload()
      unit.name.should.eql 'Tassadar'

      unit.update $set: {name: 'Fenix'}
      unit.reload()
      unit.name.should.eql 'Fenix'

    itSync 'should build model', ->
      unit = Unit.build name: 'Zeratul'
      unit.name.should.eql 'Zeratul'

    itSync 'should create model', ->
      unit = Unit.create name: 'Zeratul'
      unit.toHash().should.eql {name : 'Zeratul', _id : unit._id, _class : 'Unit'}
      Unit.first().name.should.eql 'Zeratul'

    itSync 'should delete all models', ->
      Unit.create name: 'Zeratul'
      Unit.count().should.eql 1
      Unit.delete()
      Unit.count().should.eql 0

    itSync "should allow to read object as hash, without unmarshalling", ->
      units = $db.collection 'units'
      units.save unit
      units.first({}, object: false).should.eql unit.toHash()

    itSync 'should reload model', ->
      unit = Unit.create name: 'Zeratul'
      unit.name = 'Jim'
      unit.reload()
      unit.name.should.eql 'Zeratul'

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

    itSync 'should perform CRUD', ->
      # Create.
      units = $db.collection 'units'
      units.save unit
      _(unit._id).should.exist

      item = unit.items[0]
      _(item._id).should.not.exist

      # Read.
      units.count().should.eql 1
      unit2 = units.first()
      unit2.toHash().should.eql unit.toHash()

      item = unit.items[0]
      _(item._id).should.not.exist

      # Update.
      unit.items[0].name = 'Psionic blade level 3'
      item = new Tmp.Item name: 'Power suit'
      unit.items.push item
      units.save unit
      units.count().should.eql 1
      unit2 = units.first()
      unit2.toHash().should.eql unit.toHash()

      # Delete.
      units.delete unit
      units.count().should.eql 0

    itSync "should have :_parent reference to the main object", ->
      units = $db.collection 'units'
      units.save unit
      unit = units.first()
      _(unit._parent).should.not.exist
      unit.items[0]._parent.should.eql unit

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
    post.toMongo().should.eql hash

    [post._id, hash._id] = ['some id', 'some id']
    post.toMongo().should.eql hash

    # Converting from mongo.
    Model._fromMongo(hash).toMongo().should.eql hash