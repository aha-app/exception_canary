//= require jquery
//= require jquery_ujs

$(document).on('ready', function() {
  $('#show-more').on('click', function(event) {
    $('.backtrace').css('height', 'auto');
    $('#show-more').remove();
    event.preventDefault();
  });
});
