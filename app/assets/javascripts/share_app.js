$(document).ready(function(){
  $('.dialog-modal').dialog({ autoOpen: false, modal: true, width: 500 });

  $('.dialog_link').click(function() {
    $('.share-app').dialog('open');
    return false;
  });

  $('.votable').one('click', '.vote', function() {
    $('.share-event').dialog('open');
  });

  $('.share-button').click( function(event) {
    event.preventDefault();
    var message = $('.dialog-modal textarea').val();

    Scheddo.YammerApi.publicMessage(message);

    $('#dialog').dialog('close');
  });
});
