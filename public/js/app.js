(function() {
  var buildLink, clearRecordCallback, newRecordCallback, templates;

  templates = {
    record: buildLink = function(data) {
      return '<li class="list-group-item record" style="display:none;"><span class="badge clear-record">clear</span><a href="/' + data.hash + '">localhost:5000/' + data.hash + '</a><br><em class="text-muted">Expires: ' + data.expirationTimePretty + '</em></li>';
    }
  };

  newRecordCallback = function(data, status, xhr) {
    var newRecord;
    if (status === "success") {
      newRecord = $(templates.record(data));
      $('.current-records').prepend(newRecord);
      return newRecord.slideDown();
    } else {
      return console.log("error saving record");
    }
  };

  clearRecordCallback = function(data, status, xhr) {
    if (status === "success") {
      return console.log('deleted', data, status);
    } else {
      return console.log("error saving record");
    }
  };

  $('.clear-record').on('click', function(e) {
    var record;
    record = $(e.target).closest('.record');
    record.slideUp();
    return $.ajax({
      type: "POST",
      url: "/delete/" + record.attr('data-hash'),
      success: clearRecordCallback,
      error: clearRecordCallback
    });
  });

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
      success: newRecordCallback,
      error: newRecordCallback
    });
  });

}).call(this);
