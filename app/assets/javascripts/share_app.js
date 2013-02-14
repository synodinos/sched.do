$(document).ready(function(){
  $('#dialog').dialog({ autoOpen: false, modal: true, width: 500 });
  $('.dialog_link').click(function() {
    $('#dialog').dialog('open');
    return false;
  });

  $('.votable').one('click', '.vote', function() {
    $('#dialog').dialog('open');
  });

  $('.share-button').click( function(event) {
    event.preventDefault();
    var message = $('#dialog textarea').val();

    Scheddo.YammerApi.publicMessage(message);

    $('#dialog').dialog('close');
  });
});
