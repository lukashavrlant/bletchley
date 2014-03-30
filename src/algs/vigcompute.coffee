combinatorics = require '../utils/combinatorics'
viglength = require './viglength'
_ = require '../libs/underscore'

module.exports =
  crack: (ciphertext, langstats, minlen = 4, maxlen = 20) -> 
    data = {'words':{}}
    keylengths = @computeKeylens ciphertext, minlen, maxlen, data
    if _.isEmpty keylengths
      return false
    result = viglength.crackUsingLengths ciphertext, langstats, keylengths
    data.key = result.key
    data.meta = result.meta
    data

  computeKeylens: (text, minlen, maxlen, data) ->
    indices = @matchingSubstring text, minlen, maxlen
    divs = []
    for word, ind of indices
      data.words[word] = ind
      combs = combinatorics.combinations [0...ind.length], 2
      diffs = _.map combs, (comb) -> Math.abs(ind[comb[0]] - ind[comb[1]])
      diffs.map(@divisors).map((x) -> x.map((y) -> divs.push y))
    divs = _.uniq divs
    divs = _.filter divs, (x) -> x <= 100
    divs.sort (a, b) -> a - b

  divisors: (num) ->
    divisors = [num]
    for i in [2..Math.round Math.sqrt num] when num % i == 0
      divisors.push i
      div = num / i
      divisors.push div if div != i
    divisors    

  matchingSubstring: (text, minlen, maxlen) ->
    for i in [maxlen..minlen] by -1
      temp = @substrings text, i
      if !_.isEmpty temp
        return temp
    false

  substrings: (text, len) ->
    positions = {}
    for i in [0..text.length - len]
      part = text.slice i, len + i
      if positions[part]
        positions[part].push i
      else
        positions[part] = [i]
    fpositions = {}
    for str, indices of positions
      if indices.length > 1
        fpositions[str] = indices
    fpositions
