vigenere = require '../ciphers/vigenere'
cbrute = require './cbrute'
textanalyzer = require './textanalyzer'
_ = require '../libs/underscore'

module.exports =
  crack: (ciphertext, langstats, maxkeylen = 20) ->
    meta = {'meta':[]}
    keys = @getKeys ciphertext, langstats, maxkeylen
    texts = keys.map (key) -> vigenere.decrypt ciphertext, key
    for i in [0...keys.length]
      meta.meta.push [keys[i], texts[i].slice(0, 42)]
    result = @mostmeaningful texts, [2..maxkeylen], langstats, meta
    meta.key = keys[result]
    meta

  mostmeaningful: (texts, keylengths, langstats, meta) ->
    ranked = (for text, i in texts
          sim = textanalyzer.similarity(text, langstats) * (keylengths[i] + 10)
          meta.meta[i].push Math.round sim / 10
          [sim, i])
    ranked.sort (a, b) -> a[0] - b[0]
    ranked[0][1]

  getKeys: (ciphertext, langstats, maxkeylen) ->
    for i in [2..maxkeylen]
      lines = @splitText ciphertext, i
      keys = lines.map (text) -> (cbrute.crack(text, langstats).key or 'a')
      keys.join ''

  splitText: (text, keylen) ->
    for i in [0...keylen]
      (text[c] for c in [i...text.length] by keylen).join ''

  crackUsingLength: (ciphertext, langstats, length) ->
    result = {'meta':[]}
    lines = @splitText ciphertext, length
    vigkey = (for line in lines
          caesarKey = (cbrute.crack(line, langstats).key or 'a')
          result.meta.push [line.slice(0, 42), caesarKey]
          caesarKey)
    result.key = vigkey.join ''
    result

  crackUsingLengths: (ciphertext, langstats, lengths) ->
    keys = (@crackUsingLength(ciphertext, langstats, len) for len in lengths)
    keylengths = (x.key.length for x in keys)
    texts = _.map keys, (key) -> vigenere.decrypt ciphertext, key.key
    data = {"meta":[]}
    for i in [0...keys.length]
      data.meta.push [keys[i].key, texts[i].slice 0, 42]
    result = @mostmeaningful texts, keylengths, langstats, data
    data.key = keys[result].key
    data
