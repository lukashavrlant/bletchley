_ = require '../libs/underscore'
require '../utils/underext'
caesar = require '../ciphers/caesar'
viglength = require './viglength'
vigcompute = require './vigcompute'
textanalyzer = require './textanalyzer'
string = require '../utils/string'

module.exports =
  iocByCounter: (occ) ->
    N = 0
    for k, v of occ
      N += v
    s = _.sum _.map(string.alphabet, ((c) -> occ[c] * (occ[c] - 1)))
    s / (N * (N - 1))

  ioc: (text) ->
    occ = textanalyzer.counter text
    for c in string.alphabet when not occ[c]
      occ[c] = 0

    N = text.length
    s = _.reduce _.map(string.alphabet, ((c) -> occ[c] * (occ[c] - 1))), (a, b) -> a + b
    s / (N * (N - 1))

  findKeylen: (text, keylens, iocl, data, similarBound = 0.1) -> 
    splits = (viglength.splitText text, keylen for keylen in keylens)
    indices = (for texts, i in splits
          iocs = (@ioc text for text in texts)
          index = _.reduce iocs, (a, b) -> a + b
          [index /= texts.length, keylens[i]])
    data.indices = indices
    indices.sort (a, b) -> Math.abs(a[0] - iocl) - Math.abs(b[0] - iocl)
    indices = _.filter indices, (x) -> Math.abs(x[0] - indices[0][0]) < iocl * similarBound
    indices.sort((a, b) -> a[1] - b[1])[0][1]

  crack: (ciphertext, langstats, maxguesslength = 15, minsubstring = 4, maxsubstring = 20) ->
    data = {'words':{}}
    keylengths = vigcompute.computeKeylens ciphertext, minsubstring, maxsubstring, data
    data.kasiskikeylengths = keylengths.slice 0
    keylengths = _.uniq [2..maxguesslength].concat keylengths
    data.keylengths = keylengths
    keylen = @findKeylen ciphertext, keylengths, langstats.ioc, data
    res = viglength.crackUsingLength ciphertext, langstats, keylen
    data.key = res.key
    data.keylen = keylen
    data.blocks = res.meta
    data
