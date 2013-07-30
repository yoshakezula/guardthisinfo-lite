(function() {
  var bindClearRecordCallback, buildLink, clearRecordCallback, expirationSpan, expirationSpanHash, expirationSpans, newRecordCallback, scrollToNewRecord, startExpirationCounter, templates, _fn, _i, _len;

  templates = {
    record: buildLink = function(data) {
      return '<li data-hash="' + data.hash + '" class="list-group-item record record--highlighted js-record" style="display:none;"><span class="badge clear-record js-clear-record">delete</span><a href="/' + data.hash + '" class="record__url">www.guardthis.info/' + data.hash + '</a><br><em class="text-muted js-expiration__wrapper expiration__wrapper">Expires in <span class="expiration__minutes js-expiration__minutes">' + data.expirationMinutes + '</span>&nbsp;min</em></li>';
    }
  };

  scrollToNewRecord = function(record) {
    var recordBottom, scrollBottom;
    recordBottom = record.offset().top + record.height();
    scrollBottom = window.innerHeight + window.scrollY;
    if (scrollBottom < recordBottom) {
      return $('body').animate({
        scrollTop: recordBottom - window.innerHeight + 30
      });
    }
  };

  newRecordCallback = function(data, status, xhr) {
    var newRecord;
    if (status === "success" && !data.error) {
      $('.current-records__wrapper').slideDown();
      $('.secure-text').val('');
      newRecord = $(templates.record(data));
      $('.current-records').prepend(newRecord);
      newRecord.slideDown(function() {
        scrollToNewRecord(newRecord);
        return newRecord.removeClass('record--highlighted');
      });
      $('.js-submit').attr('disabled', false);
      startExpirationCounter($(newRecord).find('.js-expiration__minutes')[0]);
      return bindClearRecordCallback();
    } else {
      return console.log("error saving record");
    }
  };

  clearRecordCallback = function(data, status, xhr) {
    if (status === "success") {
      return console.log('deleted');
    } else {
      return console.log("error saving record");
    }
  };

  $('.js-dismiss').on('click', function(e) {
    var target;
    target = $(e.target).closest('.js-dismiss-target');
    return target.slideUp();
  });

  startExpirationCounter = function(expirationSpan) {
    return setInterval((function() {
      var min, recordWrapper;
      min = expirationSpan.textContent;
      if (parseInt(min) > 1) {
        return expirationSpan.textContent = min - 1;
      } else {
        recordWrapper = $(expirationSpan).closest('.js-record');
        recordWrapper.find('a').after('<em class="text-muted record__url">www.guardthis.info/' + recordWrapper.attr('data-hash') + '</em>').remove();
        $(expirationSpan).closest('.js-expiration__wrapper').html("Expired");
        return min = void 0;
      }
    }), 60000);
  };

  expirationSpans = $('.js-expiration__minutes');

  expirationSpanHash = {};

  _fn = function(expirationSpan) {
    return startExpirationCounter(expirationSpan);
  };
  for (_i = 0, _len = expirationSpans.length; _i < _len; _i++) {
    expirationSpan = expirationSpans[_i];
    _fn(expirationSpan);
  }

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
