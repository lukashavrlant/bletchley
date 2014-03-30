caesar = require '../../ciphers/caesar'

describe 'caesar', () ->
  describe '#encrypt()', () ->
    it 'should encrypt opentext', () ->
      caesar.encrypt('ahoj', 'b').should.equal('bipk')

    it 'should encrypt empty string without error', () ->
      caesar.encrypt('', 'z').should.equal ''
    
    it 'should encrypt and keep spaces', () -> 
      caesar.encrypt('ahoj svete', 'w').should.equal('wdkf orapa')

  describe '#decrypt()', () ->
    it 'should decrypt ciphertext', () ->
      caesar.decrypt('bipk', 'b').should.equal('ahoj')

    it 'should decrypt empty string without error', () ->
      caesar.decrypt('', 'w').should.equal('')