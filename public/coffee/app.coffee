templates = 
  record: buildLink = (data) ->
    '<li class="list-group-item record" style="display:none;"><span class="badge clear-record">clear</span><a href="/'+ data.hash + '">localhost:5000/' + data.hash + '</a><br><em class="text-muted">Expires: ' + data.expirationTimePretty + '</em></li>'

newRecordCallback = (data, status, xhr) -> 
  if status == "success"
    newRecord = $(templates.record(data))
    $('.current-records').prepend newRecord
    newRecord.slideDown()
  else
    console.log "error saving record"

clearRecordCallback = (data, status, xhr) ->
  if status == "success"
    console.log 'deleted', data, status
  else
    console.log "error saving record"

$('.clear-record').on 'click', (e) ->
  record = $(e.target).closest '.record'
  record.slideUp()
  $.ajax
    type:"POST"
    url: "/delete/" + record.attr 'data-hash'
    success: clearRecordCallback
    error: clearRecordCallback

$('.js-submit').on 'click.submit', ->
  expirationMinutes = $('.expiration-time-buttons .active input').attr('data-expiration-minutes')
  text = $('.secure-text').val()
  $.ajax
    type:"POST"
    url: "/"
    data: 
      text : text
      expirationMinutes : expirationMinutes
    success: newRecordCallback
    error: newRecordCallback