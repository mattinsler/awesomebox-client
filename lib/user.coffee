crypto = require 'crypto'

class User
  constructor: (data) ->
    @[k] = v for k, v of data
    
    hash = crypto.createHash('md5')
    hash.update(@email.toLowerCase())
    @gravatar_hash = hash.digest('hex')

module.exports = User
