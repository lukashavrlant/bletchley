_ = require '../libs/underscore'

_.mixin 
  sum: (arr) ->
    s = 0
    for x in arr
      s += x
    s
