mongoose = require 'mongoose'
moment = require 'moment'

formatTime = (time) ->
  moment(time).format('MMM Do @ h:mmA')

recordSchema = new mongoose.Schema
  text: 
    type: String
    required: true
  expirationMinutes:
    type: Number
    required: true
    default: 15
    max: 120
  auth_token:
    type: String
    required: true
    unique: true
    index: true
  hash: 
    type: String
    required: true
    unique: true
    index: true
  expirationTime:
    type: Date
    required: true
  expirationTimePretty:
    type: String
    set: formatTime
  expired:
    type: Boolean
    default: false

Record = mongoose.model 'Record', recordSchema
exports.Record = Record