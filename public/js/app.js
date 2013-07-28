(function() {
  var callback;

  callback = function(a, b, c) {
    return console.log(a, b, c);
  };

  $('.js-submit').on('click.submit', function() {
    var expirationMinutes, text;
    expirationMinutes = $('.expiration-time-buttons .active input').attr('data-expiration-minutes');
    text = $('.secure-text').val();
    return $.ajax({
      type: "POST",
      url: "/",
      data: {
        text: text,
        expirationMinutes: expirationMinutes
      },
      success: callback,
      error: callback
    });
  });

}).call(this);
