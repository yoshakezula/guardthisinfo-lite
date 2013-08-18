express = require 'express'
path = require 'path'
http = require 'http'
stylus = require 'stylus'
schema = require './db'
mongoose = require 'mongoose'
nib = require 'nib'
crypto = require 'crypto'
MongoStore = require('connect-mongo')(express)
app = express()

dbURI = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/guardthisinfo'

#Set environment
app.set 'env', process.env.NODE_ENV || 'development'

mongoose.connect dbURI, (err, res) ->
  console.log if err then 'ERROR connecting to: ' + dbURI + '. ' + err else 'Succeeded connected to: ' + dbURI

app.configure () ->
  if 'development' == app.get 'env'
    stylusCompile = (str, path) ->
      stylus(str).set('filename', path).set('compress', true).use nib()
    app.use express.errorHandler()
    app.use stylus.middleware
      src: __dirname + '/public'
      compile: stylusCompile
  if 'production' == app.get 'env'
    app.use forceSsl(req, res, next) ->
      if req.header 'x-forwarded-proto' != 'https'
        res.redirect "https://#{req.header 'host'}#{req.url}"
      else
        next()
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon __dirname + '/public/img/favicon.png'
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.cookieParser('guardthis')
  app.use express.cookieSession('9af2044f50b506be7a194bf8af0aa1ee6d8afdbb')
  app.use express.session
    secret: '9af2044f50b506be7a194bf8af0aa1ee6d8afdbb'
    store: new MongoStore {url: dbURI}
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

findRecords = (req, res, next) ->
  query = schema.Record.find {auth_token: req.signedCookies.auth_token}
  query.select 'hash expirationTime'
  query.sort {expirationTime: -1}
  query.exec (err, result) ->
    if err
      console.log 'error looking up existing records for auth_token ' + req.signedCookies.auth_token
    else
      for record in result
        do (record) ->
          record.timeLeft = parseInt (record.expirationTime - new Date()) / 60000
      res.locals.existingRecords = result
    next()

app.get '/', authenticate, findRecords, (req, res) -> 
  res.render 'index'

app.get '/:hash', authenticate, findRecords, (req, res) ->
  query = schema.Record.findOne {hash: req.params.hash}
  query.where('expirationTime').gt(new Date())
  query.select 'text hash expirationTime'
  query.exec (err, result) ->
    if err || result == null
      console.log 'error finding record with hash: ' + req.params.hash
      if err then console.log err
      res.render 'index', { foundRecord: 'not found'}
    else
      res.render 'index', 
        foundRecord: if (err || result == null) then 'not found' else result
        timeLeft: parseInt (result.expirationTime - new Date()) / 60000

app.post '/', authenticate, (req, res) ->
  reqBody = req.body
  expirationTime = new Date()
  expirationTime.setMinutes(expirationTime.getMinutes() + parseInt reqBody.expirationMinutes)
  newRecord = new schema.Record
    text: reqBody.text
    expirationMinutes: parseInt reqBody.expirationMinutes
    hash: crypto.randomBytes(20).toString('hex')
    auth_token: req.signedCookies.auth_token
    expirationTime: expirationTime
  newRecord.save (err) -> 
    if err 
      console.log 'error saving record:', newRecord.hash
      console.log err
      res.send { error: err }
    else
      console.log 'new record saved with hash ' + newRecord.hash
      res.send
        hash: newRecord.hash
        expirationMinutes: newRecord.expirationMinutes
        timeLeft: parseInt (newRecord.expirationTime - new Date()) / 60000

app.post '/delete/:hash', authenticate, (req, res) ->
  query = schema.Record.findOneAndRemove {hash: req.params.hash}
  query.exec (err, result) ->
    if err  || !result
      console.log 'record to delete not found: ' + req.params.hash 
      res.send {errors: 'record not found'}
    else
      console.log 'removed record with hash: ' + result.hash
      res.send {removed: result.hash}



port = process.env.PORT || 3000

http.createServer(app).listen port
console.log "Express server listening on port " + port
console.log 'Environment: ' + app.get 'env'