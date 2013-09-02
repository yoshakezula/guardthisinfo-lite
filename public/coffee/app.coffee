templates = 
  record: buildLink = (data) ->
    '<li data-hash="' + data.hash + '" class="list-group-item record record--highlighted js-record" style="display:none;"><span class="badge clear-record js-clear-record">delete</span><a href="/'+ data.hash + '" class="record__url">www.guardthis.info/' + data.hash + '</a><br><em class="text-muted js-expiration__wrapper expiration__wrapper">Expires in <span class="expiration__minutes js-expiration__minutes">' + data.expirationMinutes + '</span>&nbsp;min</em></li>'

scrollToNewRecord = (record) ->
  recordBottom = record.offset().top + record.height()
  scrollBottom = window.innerHeight + window.scrollY
  if scrollBottom < recordBottom
    $('body').animate({scrollTop: recordBottom - window.innerHeight + 30})


newRecordCallback = (data, status, xhr) -> 
  if status == "success" && !data.error
    $('.current-records__wrapper').slideDown()
    $('.secure-text').val('')
    
    newRecord = $(templates.record(data))
    $('.current-records').prepend newRecord
    newRecord.slideDown -> 
      scrollToNewRecord(newRecord)
      newRecord.removeClass 'record--highlighted'

    $('.js-submit').attr 'disabled', false
    startExpirationCounter $(newRecord).find('.js-expiration__minutes')[0]
    bindClearRecordCallback()
  else
    console.log "error saving record"

clearRecordCallback = (data, status, xhr) ->
  if status == "success"
    console.log 'deleted'
  else
    console.log "error saving record"

$('.js-dismiss').on 'click', (e) ->
  target = $(e.target).closest '.js-dismiss-target'
  target.slideUp()

startExpirationCounter = (expirationSpan) ->
  setInterval (() ->
    min = expirationSpan.textContent
    if parseInt(min) > 1
      expirationSpan.textContent = min - 1
    else
      recordWrapper = $(expirationSpan).closest('.js-record')
      recordWrapper.find('a').after('<em class="text-muted record__url">www.guardthis.info/' + recordWrapper.attr('data-hash') + '</em>').remove()
      $(expirationSpan).closest('.js-expiration__wrapper').html "Expired"
      min = undefined
  ), 60000

expirationSpans = $('.js-expiration__minutes')
expirationSpanHash = {}
for expirationSpan in expirationSpans
  do (expirationSpan) ->
    startExpirationCounter(expirationSpan)

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

$('.app').on 'submit', (e) -> e.preventDefault()

$('.js-site-info__faq__show-more').on 'click', ->
  $('.site-info__faq').addClass 'expanded'
  $('.js-site-info__faq__show-more').remove()


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