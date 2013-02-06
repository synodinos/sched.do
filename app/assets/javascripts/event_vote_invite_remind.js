//= require jquery.event
//= require yammer_feed
//= require votes

if(Scheddo.YammerApi.isYammerUser()){
  $.widget('custom.yammerAutocomplete',
    $.ui.autocomplete,
      Scheddo.autocompleteConfiguration({
        translator: Scheddo.Translators.AutocompletePost,
        autocompleteListSelector: '.invitation-autocomplete-suggestions'
      }));

  $.widget('custom.yammerShareAutocomplete',
    $.ui.autocomplete,
      Scheddo.autocompleteConfiguration({
        translator: Scheddo.Translators.eventShare,
        autocompleteListSelector: '.share-event .invitation-autocomplete-suggestions',
        maxUsersReturned: 0
      }));

  $('#auto-complete').yammerAutocomplete();
  $('.share-event #auto-complete').yammerShareAutocomplete();
}
