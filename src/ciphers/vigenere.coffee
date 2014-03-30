string = require '../utils/string'

module.exports =
  encrypt: (opentext, key) ->
    keycodes = (c.charCodeAt() - 'a'.charCodeAt() for c in key)
    i = -1
    cletters = (for c in opentext
          if string.isWhiteSpace c
            c
          else
            i += 1
            string.shiftchar(c, keycodes[i % key.length]))
    cletters.join ''

  decrypt: (opentext, key) ->
    keycodes = (c.charCodeAt() - 'a'.charCodeAt() for c in key)
    cletters = for i in [0...opentext.length]
      string.shiftcharback opentext[i], keycodes[i % key.length]
    cletters.join ''