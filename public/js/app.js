(function() {
  var bindClearRecordCallback, buildLink, clearRecordCallback, newRecordCallback, templates;

  templates = {
    record: buildLink = function(data) {
      return '<li data-hash="' + data.hash + '" class="list-group-item record js-record" style="display:none;"><span class="badge clear-record js-clear-record">clear</span><a href="/' + data.hash + '">guardthis.info/' + data.hash + '</a><br><em class="text-muted">Expires: ' + data.expirationTimePretty + '</em></li>';
    }
  };

  newRecordCallback = function(data, status, xhr) {
    var newRecord;
    if (status === "success" && !data.error) {
      $('.current-records__wrapper').slideDown();
      $('.secure-text').val('');
      newRecord = $(templates.record(data));
      $('.current-records').prepend(newRecord);
      newRecord.slideDown();
      $('.js-submit').attr('disabled', false);
      return bindClearRecordCallback();
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

  $('.js-dismiss').on('click', function(e) {
    var target;
    target = $(e.target).closest('.js-dismiss-target');
    return target.slideUp();
  });

  bindClearRecordCallback = function() {
    $('.js-clear-record').off;
    return $('.js-clear-record').on('click', function(e) {
      var record;
      record = $(e.target).closest('.js-record');
      record.slideUp(function() {
        return record.remove();
      });
      return $.ajax({
        type: "POST",
        url: "/delete/" + record.attr('data-hash'),
        success: clearRecordCallback,
        error: clearRecordCallback
      });
    });
  };

  bindClearRecordCallback();

  $('.js-submit').on('click.submit', function() {
    var expirationMinutes, text;
    expirationMinutes = $('.expiration-time-buttons .active input').attr('data-expiration-minutes');
    text = $('.secure-text').val().trim();
    if (text.length === 0) {
      $('.secure-text').addClass('bounce');
      return setTimeout((function() {
        return $('.secure-text').removeClass('bounce');
      }), 2000);
    } else {
      $('.js-submit').attr('disabled', true);
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
    }
  });

}).call(this);
