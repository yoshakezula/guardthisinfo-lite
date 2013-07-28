mongoose = require 'mongoose'

recordSchema = new mongoose.Schema
  text: String
  expirationMinutes: Number
  url: String
  createdTime: Date
  expired: type: Boolean, default: false

Record = mongoose.model 'Record', recordSchema
exports.Record = Record