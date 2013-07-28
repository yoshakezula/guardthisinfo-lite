express = require 'express'
path = require 'path'
http = require 'http'
stylus = require 'stylus'
schema = require './db'
mongoose = require 'mongoose'
nib = require 'nib'
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
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.get '/', (req, res) -> res.render 'index', title:'guardthis.info'

app.post '/', (req, res) ->
  reqBody = req.body
  newRecord = new schema.Record
    text: reqBody.text
    expirationMinutes: parseInt reqBody.expirationMinutes
  newRecord.save (err) -> console.log if err then 'error' else newRecord

port = process.env.PORT || 3000

mongoose.connect dbURI, (err, res) ->
  console.log if err then 'ERROR connecting to: ' + dbURI + '. ' + err else 'Succeeded connected to: ' + dbURI

http.createServer(app).listen port
console.log "Express server listening on port " + port
console.log 'Environment: ' + app.get 'env'