(function() {
  var buildLink, callback;

  buildLink = function(hash) {
    return '<a href="http://localhost:5000/' + hash + '">http://localhost:5000/' + hash + '</a>';
  };

  callback = function(data, status, xhr) {
    if (status === "success") {
      return $('.current-urls').append(buildLink(data.hash));
    } else {
      return console.log("error saving record");
    }
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
