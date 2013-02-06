Namespaced.declare('Scheddo.Translators');

Scheddo.Translators.eventShare = (function(){
  var setRemoveClickEvent = function(markup, invitee){
    markup.children('.remove').click(function(){
      Scheddo.Util.removeInviteeFromQueue(invitee);
      markup.remove();
    });
  };

  return {
    addMethodsToGroup: function(group){
      group.submit = function(event, form){
        Scheddo.Util.inviteeQueue.push(group);
        markup = $(Scheddo.Templates.getGroupInviteeTemplate(group));
        setRemoveClickEvent(markup, group);

        $('#invite_groups').hide();
        $('.invited-groups.list-invitees').append(markup);
      };

      return group;
    },

    translateGroups: function(groupData){
      var self = this;
      return _(groupData).map(function(groupObject) {
        var group = Scheddo.Translators.translateGroup(groupObject);
        return self.addMethodsToGroup(group);
      }).reverse();
    },

    normalizeTranslatedResponse: function(term, response){
      var self = this;
      return function(yammerData){
        var groups = self.translateGroups(yammerData.group);

        response(groups);
      }
    }
  }
})();
