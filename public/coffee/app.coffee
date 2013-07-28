buildLink = (hash) ->
  '<a href="http://localhost:5000/' + hash + '">http://localhost:5000/' + hash + '</a>' 

callback = (data, status, xhr) -> 
  if status == "success"
    $('.current-urls').append buildLink(data.hash)
  else
    console.log "error saving record"

$('.js-submit').on 'click.submit', ->
  expirationMinutes = $('.expiration-time-buttons .active input').attr('data-expiration-minutes')
  text = $('.secure-text').val()
  $.ajax
    type:"POST"
    url: "/"
    data: 
      text : text
      expirationMinutes : expirationMinutes
    success: callback
    error: callback