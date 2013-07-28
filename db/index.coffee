mongoose = require 'mongoose'

recordSchema = new mongoose.Schema
  text: String
  expirationMinutes:
    type: Number
    required: true
    default: 15
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
  expired:
    type: Boolean
    default: false

Record = mongoose.model 'Record', recordSchema
exports.Record = Record