templates = 
  record: buildLink = (data) ->
    '<li data-hash="' + data.hash + '" class="list-group-item record js-record" style="display:none;"><span class="badge clear-record js-clear-record">clear</span><a href="/'+ data.hash + '">localhost:5000/' + data.hash + '</a><br><em class="text-muted">Expires: ' + data.expirationTimePretty + '</em></li>'

newRecordCallback = (data, status, xhr) -> 
  if status == "success"
    newRecord = $(templates.record(data))
    $('.current-records').prepend newRecord
    newRecord.slideDown()
    $('.js-submit').attr 'disabled', false
    bindClearRecordCallback()
  else
    console.log "error saving record"

clearRecordCallback = (data, status, xhr) ->
  if status == "success"
    console.log 'deleted', data, status
  else
    console.log "error saving record"

$('.js-dismiss').on 'click', (e) ->
  target = $(e.target).closest '.js-dismiss-target'
  target.slideUp()

bindClearRecordCallback = () ->
  $('.js-clear-record').off
  $('.js-clear-record').on 'click', (e) ->
    record = $(e.target).closest '.js-record'
    record.slideUp(() -> record.remove())
    $.ajax
      type:"POST"
      url: "/delete/" + record.attr 'data-hash'
      success: clearRecordCallback
      error: clearRecordCallback

bindClearRecordCallback()

$('.js-submit').on 'click.submit', ->
  expirationMinutes = $('.expiration-time-buttons .active input').attr('data-expiration-minutes')
  text = $('.secure-text').val().trim()
  if text.length == 0
    $('.secure-text').addClass 'bounce'
    setTimeout (()->$('.secure-text').removeClass 'bounce'), 2000
  else
    $('.js-submit').attr 'disabled', true
    $.ajax
      type:"POST"
      url: "/"
      data: 
        text : text
        expirationMinutes : expirationMinutes
      success: newRecordCallback
      error: newRecordCallback