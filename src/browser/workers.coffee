viglength = require '../algs/viglength'
vigcompute = require '../algs/vigcompute'
friedman = require '../algs/friedman'

action = 
  'viglength': (data) ->
    viglength.crackUsingLength data.ciphertext, data.statistics, data.keylen
  'vigcrack': (data) ->
    viglength.crack data.ciphertext, data.statistics, data.maxkeylen
  'vigkeylenfind': (data) ->
    vigcompute.crack data.ciphertext, data.statistics, data.minlen
  'friedman': (data) ->
    friedman.crack data.ciphertext, data.statistics

self.addEventListener 'message', (event) ->
  postMessage action[event.data.action](event.data)