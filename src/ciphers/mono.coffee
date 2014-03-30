string = require '../utils/string'
_ = require '../libs/underscore'

###
Mohoalphabetic cipher module
###

module.exports =
  encrypt: (opentext, key) ->
    password = @passgen key
    string.replaceChars opentext, password

  decrypt: (ciphertext, key) ->
    password = @passgen key
    inversed = {}
    acode = 'a'.charCodeAt()
    for c, i in password
      inversed[c] = String.fromCharCode i + acode
    (inversed[c] for c in ciphertext).join ''

  passgen: (key) ->
    key = _.uniq(key).join ''
    rest = _.filter(string.alphabet, (c) -> _.indexOf(key, c) == -1).join ''
    key + rest
