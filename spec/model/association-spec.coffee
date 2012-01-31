require '../helper'

describe 'Model Associations', ->
  withMongo()

  it.sync "should model associations", ->
    class Tmp.Post extends Model
      @collection 'posts'

      comments: ->
        Tmp.Comment.find(postId: @_id).sort text: -1

    class Tmp.Comment extends Model
      @collection 'comments'

    post1 = Tmp.Post.create text: 'Post 1'
    comment1 = post1.comments().create text: 'Comment 1'
    comment2 = post1.comments().create text: 'Comment 2'

    post2 = Tmp.Post.create text: 'Post 2'
    comment3 = post2.comments().create text: 'Comment 3'

    post1.comments().count().should.eql 2
    list = post1.comments().all()
    list.map((o) -> o.text).should.eql ['Comment 2', 'Comment 1']