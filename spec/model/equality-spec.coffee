require '../helper'

describe 'Model Equality', ->
  withMongo()

  it "should check for equality based on model attributes", ->
    class Unit extends Model
    class Item extends Model

    unit1 = new Unit name: 'Zeratul'
    unit1.items = [new Item(name: 'Psionic blade')]

    unit2 = new Unit name: 'Zeratul'
    unit2.items = [new Item(name: 'Psionic blade')]

    unit1.eq(unit2).should be: true

    unit1.items[0].name = 'Power suit'
    unit1.eq(unit2).should be: false

  it "should compare with non models (from errors)", ->
    class Unit extends Model

    unit = new Unit()
    unit.eq(1).should be: false
    unit.eq(null).should be: false