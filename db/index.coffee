mongoose = require 'mongoose'


textValidator = (v) -> v.length < 1000

recordSchema = new mongoose.Schema
  text: 
    type: String
    required: true
    trim: true
    validate: [textValidator, 'text length error']
  expirationMinutes:
    type: Number
    required: true
    default: 15
    max: 120
  auth_token:
    type: String
    required: true
    index: true
  hash: 
    type: String
    required: true
    unique: true
    index: true
  expirationTime:
    type: Date
    required: true
  expired:
    type: Boolean
    default: false

Record = mongoose.model 'Record', recordSchema
exports.Record = Record