vigenere = require '../../ciphers/vigenere'

describe 'vigenere', () ->
  describe '#encrypt()', () ->
    it 'with one-letter kry it should encrypt like caesar cipher', () ->
      vigenere.encrypt('ahoj', 'b').should.equal('bipk')

    it 'should encrypt opentext', () ->
      vigenere.encrypt('dobryden', 'asd').should.equal('dgerqgef')

    it 'should encrypt empty string without error', () ->
      vigenere.encrypt('', 'z').should.equal ''
    
    it 'should encrypt and keep spaces', () -> 
      vigenere.encrypt('ahoj svete', 'klic').should.equal('kswl cgmvo')

  describe '#decrypt()', () ->
    it 'with one-letter kry it should decrypt like caesar cipher', () ->
      vigenere.decrypt('bipk', 'b').should.equal('ahoj')

    it 'should encrypt opentext', () ->
      vigenere.decrypt('dgerqgef', 'asd').should.equal('dobryden')

    it 'should decrypt empty string without error', () ->
      vigenere.decrypt('', 'w').should.equal('')
