string = require '../utils/string'
combinatorics = require '../utils/combinatorics'
textanalyzer = require './textanalyzer'
_ = require '../libs/underscore'

###
CaesarTriangle module
###
module.exports =
  progress: {}
  crack: (ciphertext, langstats) ->
    @progress = {}
    cLetters = @mostCommon((textanalyzer.counter ciphertext), 6)
    lLetters = @mostCommon(langstats.frequency, 3)
    topKeys = @findKeys cLetters, lLetters
    @progress['topcLetters'] = cLetters
    @progress['toplLetters'] = lLetters

    leastCounter = textanalyzer.counter ciphertext
    leastCounter[c] = 0 for c in string.alphabet when not leastCounter[c]

    cLetters = @leastCommon(leastCounter, 6)
    lLetters = @leastCommon(langstats.frequency, 3)
    leastKeys = @findKeys cLetters, lLetters, false

    finalkey = @bestKey topKeys, leastKeys

    return {'key':finalkey, 'meta':@progress}

  bestKey: (keys1, keys2) ->
    inter = _.intersection keys1, keys2
    return inter[0] if inter.length > 0
    (keys1.concat keys2)[0]

  findKeys: (cLetters, langLetters, top = true) ->
    langDist = @distances langLetters
    @progress[if top then 'toplangDist' else 'leastlangDist'] = langDist
    @progress[if top then 'topDistances' else 'leastDistances'] = []

    keys = []
    for comb in combinatorics.combinations cLetters, 3
      for perm in combinatorics.permutation comb
        permdist = @distances(perm)
        @progress[if top then 'topDistances' else 'leastDistances'].push([perm, permdist])
        if _.isEqual permdist, langDist
          keys.push perm
    @computeKey langLetters, key for key in keys

  computeKey: (langLetters, cipherLetters) ->
    c = cipherLetters[0].charCodeAt() - langLetters[0].charCodeAt()
    c += 26 if c < 0
    String.fromCharCode c + 'a'.charCodeAt()

  distances: ([a, b, c]) ->
    [@distance(a, b), @distance(a, c), @distance(b, c)]

  leastCommon: (counter, number) ->
    @_common counter, number, ([a, b], [c, d]) -> b - d

  mostCommon: (counter, number) ->
    @_common counter, number, ([a, b], [c, d]) -> d - b

  _common: (counter, number, sortfun) ->
    ([k, v] for k, v of counter).sort(sortfun)[...number].map(([a, b]) -> a).sort()

  distance: (a, b) ->
    dist = Math.abs a.charCodeAt() - b.charCodeAt()
    dist = 26 - dist if dist > 13
    dist
