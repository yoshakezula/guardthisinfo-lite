callback = (a, b, c) -> console.log a, b, c
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