string = require '../utils/string'

###
Caesar encrypt module
###
module.exports =
  makeEnTable: (key) ->
    code = string.code key
    string.alphabet.slice(code) + string.alphabet.slice(0, code)

  makeDecTable: (key) ->
    code = string.code key
    string.alphabet.slice(26 - code) + string.alphabet.slice(0, 26 - code)

  encrypt: (opentext, key) ->
    string.replaceChars opentext, this.makeEnTable key

  decrypt: (ciphertext, key) ->
    string.replaceChars ciphertext, this.makeDecTable key

  getLine: (text, firstBold = false) ->
    if firstBold
      "<td>Výstup</td><td><b>#{text[0]}</b></td>" + ("<td>#{c}</td>" for c in text.slice(1)).join ''
    else
      "<td>Vstup</td>" + ("<td>#{c}</td>" for c in text).join ''

  showTable: (key) ->
    "<tr>" + this.getLine(string.alphabet) + "<tr>" + this.getLine(this.encrypt(string.alphabet, key), true)