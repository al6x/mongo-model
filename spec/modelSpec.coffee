global.expect  = require 'expect.js'
global.p       = (args...) -> console.log args...

{Model} = require '../lib/model'
require '../lib/model/conversion'

# Namespace for temporarry objects.
global.Tmp = {}
beforeEach ->
  global.Tmp = {}

# Stubbing class loading.
Model.getClass = (name) ->
  Tmp[name] || (throw new Error "can't get '#{name}' class!")

describe "Model", ->
  it "should check for equality based on model attributes", ->
    class Unit extends Model
    class Item extends Model

    unit1 = new Unit name: 'Zeratul'
    unit1.items = [new Item(name: 'Psionic blade')]

    unit2 = new Unit name: 'Zeratul'
    unit2.items = [new Item(name: 'Psionic blade')]

    expect(unit1.eq(unit2)).to.be true

    unit1.items[0].name = 'Power suit'
    expect(unit1.eq(unit2)).to.be false

  it "should compare with non models", ->
    class Unit extends Model

    unit = new Unit()
    expect(unit.eq(1)).to.be false
    expect(unit.eq(null)).to.be false

  it "should update attributes", ->
    class Tmp.User extends Model

    u = new Tmp.User()
    u.set name: 'Alex', hasMail: 'true', age: '31', banned: 'false'
    expect([u.name, u.hasMail, u.age, u.banned]).to.eql ['Alex', 'true', '31', 'false']

  it "should provide helper for adding errors", ->
    class Unit extends Model

    unit = new Unit()
    unit.errors.add name: "can't be blank"
    expect(unit.errors).to.eql {name: ["can't be blank"]}
    unit.errors.clear()
    expect(unit.errors).to.eql {}

describe 'Attribute Conversion', ->
  it "should update only typed attribytes if casting specified", ->
    class Tmp.User extends Model
      @cast
        name    : String
        hasMail : Boolean
        age     : Number

    u = new Tmp.User()
    u.set {name: 'Alex', hasMail: 'true', age: '31'}, cast: true
    expect([u.name, u.hasMail, u.age]).to.eql ['Alex', true, 31]

    # Should skip attributes if type not specified.
    u.set {unknown: false}, cast: true
    expect(u.unknown).to.be undefined

  it "should inherit attribute types", ->
    class Tmp.User extends Model
      @cast age: Number

    class Tmp.Writer extends Tmp.User
      @cast posts: Number

    u = new Tmp.Writer()
    u.set {age: '20', posts: '12'}, cast: true
    expect([u.age, u.posts]).to.eql [20, 12]

  it 'should parse string values', ->
    cases = [
      [Boolean, 'true',       true]
      [Number,  '12',         12]
      [String,  'Hi',         'Hi']
    ]
    for cse in cases
      [type, raw, expected] = cse
      expect(Model._cast(raw, type)).to.eql expected

    expect(Model._cast('2011-08-23', Date)).to.eql (new Date('2011-08-23'))

describe "Model Conversion", ->
  it "should convert object to and from hash & array", ->
    class Tmp.Post extends Model
      @children 'tags', 'comments'

    class Tmp.Comment extends Model

    # Should aslo allow to use models that
    # are saved to array.
    # To do so we need to use toArray and afterFromHash.
    class Tmp.Tags extends Model
      constructor: -> @array = []
      push: (args...) -> @array.push args...
      toArray: -> @array
    Tmp.Post.afterFromHash = (obj, hash) ->
      obj.tags = new Tmp.Tags
      obj.tags.array = hash.tags

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

    # Converting to Hash.
    expect(post.toHash()).to.eql hash

    [post.id, hash.id] = ['some id', 'some id']
    expect(post.toHash()).to.eql hash

    # Converting from mongo.
    expect(Model.fromHash(hash).toHash()).to.eql hash

  it "chldren should have `_parent` reference to the main object", ->
    class Tmp.Unit extends Model
      @children 'items'
    class Tmp.Item extends Model

    unit = new Tmp.Unit()
    unit.items = [
      new Tmp.Item(name: 'Psionic blade')
      new Tmp.Item(name: 'Plasma shield')
    ]

    hash = unit.toHash()
    unit = Model.fromHash(hash)
    expect(unit._parent).to.be undefined
    expect(unit.items[0]._parent).to.eql unit