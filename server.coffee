express = require 'express'
path = require 'path'
http = require 'http'
stylus = require 'stylus'
schema = require './db'
mongoose = require 'mongoose'
nib = require 'nib'
crypto = require 'crypto'
# cookieSessions = require './cookie-sessions'
app = express()

dbURI = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/guardthisinfo'

#Set environment
app.set 'env', process.env.NODE_ENV || 'development'

app.configure () ->
  if 'development' == app.get 'env'
    stylusCompile = (str, path) ->
      stylus(str).set('filename', path).set('compress', true).use nib()
    app.use express.errorHandler()
    app.use stylus.middleware
      src: __dirname + '/public'
      compile: stylusCompile

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.cookieParser('guardthis')
  app.use express.cookieSession('info')
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

authenticate = (req, res, next) ->
  req.session.count = req.session.count || 0
  req.session.count++
  if !req.signedCookies.auth_token
    console.log 'new auth_token'
    res.cookie 'auth_token', crypto.randomBytes(20).toString('hex'), {httpOnly: false, signed: true, maxAge: 86400000 }
  else
    console.log 'existing auth_token'
  next()

app.get '/', authenticate, (req, res) -> 
  res.render 'index'

app.get '/:hash', authenticate, (req, res) ->
  query = schema.Record.findOne {hash: req.params.hash}
  query.select 'text'
  query.exec (err, result) ->
    res.render 'index', hash: if err then 'Not found' else result

app.post '/', authenticate, (req, res) ->
  reqBody = req.body
  newRecord = new schema.Record
    text: reqBody.text
    expirationMinutes: parseInt reqBody.expirationMinutes
    hash: crypto.randomBytes(20).toString('hex')
    auth_token: req.signedCookies.auth_token
  newRecord.save (err) -> 
    if err then console.log 'error saving record' 
    else 
      console.log 'new record saved with hash ' + newRecord.hash
      res.send {hash: newRecord.hash}


port = process.env.PORT || 3000

mongoose.connect dbURI, (err, res) ->
  console.log if err then 'ERROR connecting to: ' + dbURI + '. ' + err else 'Succeeded connected to: ' + dbURI

http.createServer(app).listen port
console.log "Express server listening on port " + port
console.log 'Environment: ' + app.get 'env'