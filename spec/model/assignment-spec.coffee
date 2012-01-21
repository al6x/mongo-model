require '../helper'

describe 'Model Attribute assignment', ->
  withMongo()

  it "should update attributes", ->
    class Tmp.User extends Model

    u = new Tmp.User()
    u.set name: 'Alex', hasMail: 'true', age: '31', banned: 'false'
    [u.name, u.hasMail, u.age, u.banned].should be: ['Alex', 'true', '31', 'false']

  it "should update only specified attributes in safe mode", ->
    class Tmp.User extends Model

      @accessible 'name', String
      @accessible 'hasMail', Boolean
      @accessible 'age', Number
      @accessible 'position'

    u = new Tmp.User()
    u.safeSet name: 'Alex', hasMail: 'true', age: '31', position: [11, 34]
    [u.name, u.hasMail, u.age, u.position].should be: ['Alex', true, 31, [11, 34]]

    # Should skip not allowed attributes.
    u.safeSet banned: false
    _(u.banned).should be: null

    # Should allow to forcefully update any attribute.
    u.set banned: false
    u.banned.should be: false

  it "should inherit assignment rules", ->
    class Tmp.User extends Model
      @accessible 'age', Number

    class Tmp.Writer extends Tmp.User
      @accessible 'posts', Number

    u = new Tmp.Writer()
    u.safeSet age: '20', posts: '12'
    [u.age, u.posts].should be: [20, 12]

  it 'should cast string values', ->
    helper = require '../../lib/helper'
    _([
      [Boolean, 'true',       true]
      [Number,  '12',         12]
      [String,  'Hi',         'Hi']
    ]).each (meta) ->
      [type, raw, expected] = meta
      helper.cast(raw, type).should be: expected

    helper.cast('2011-08-23', Date).toString().should be: (new Date('2011-08-23')).toString()