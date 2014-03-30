string = require '../utils/string'
_ = require '../libs/underscore'

module.exports =
  encrypt: (opentext, key) ->
    if opentext
      columns = @splitText opentext, key.length
      columns = _.zip key, columns
      columns = columns.sort((a, b) -> a[0].charCodeAt() - b[0].charCodeAt())
      columns = _.pluck columns, 1
      columns.join ''
    else
      ''

  decrypt: (ciphertext, key) -> 
    if ciphertext
      sortedKey = _.zip key.split(""), [0...key.length]
      sortedKey = sortedKey.sort (a, b) -> a[0].charCodeAt() - b[0].charCodeAt()
      sortedKey = _.pluck sortedKey, 1
      columns = @divideText ciphertext, ciphertext.length / key.length
      columns = _.zip sortedKey, columns
      columns = columns.sort (a, b) -> a[0] - b[0]
      columns = _.pluck columns, 1
      columns = _.zip.apply @, columns
      columns = _.flatten(columns).join ''
    else
      ''

  splitText: (text, keylen) ->
    limit = Math.ceil(text.length / keylen) * keylen
    for i in [0...keylen]
      (text[c] or 'x' for c in [i...limit] by keylen).join ''

  divideText: (opentext, length) ->
    openlength = opentext.length
    opentext += string.repeat "x", (length - (openlength % length)) % length
    (opentext.slice i, i + length for i in [0...openlength] by length)
