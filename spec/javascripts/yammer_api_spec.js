require('/assets/namespaced.js');
require('/assets/scheddo/yammer_api.js');
require('/assets/underscore.js');

describe ('Scheddo.YammerApi.setAccessToken', function(){
  it ('sets the users access token on yammer.request for oauth2', function(){
    authSetter = {
      setAuthToken: function(){
      }
    }
    spyOn(authSetter, 'setAuthToken');
    window.yam = {
      request: {
        setAuthenticator: jasmine.createSpy('yam.request.setAuthenticator'),
        getAuthenticator: function(){
          return authSetter;
        }
      }
    }
    var access_token = '123456';
    var api = Scheddo.YammerApi;
    api.setAccessToken(access_token);

    expect(yam.request.setAuthenticator).toHaveBeenCalledWith('oauth2');
    expect(authSetter.setAuthToken).toHaveBeenCalledWith(access_token);
  });
});

describe('Scheddo.YammerApi.autocomplete', function(){
  beforeEach(function(){
    window.yam = {
      request: jasmine.createSpy('yam.request')
    };
  });


  describe('ranked', function(){
    it('passes the correct default arguments to yam.request', function(){
      var term = 'foobar';
      var translateResponseData = jasmine.createSpy('translateResponseData');
      var autocomplete = Scheddo.YammerApi.autocomplete({});
      spyOn(autocomplete, 'translateResponseData').andReturn(translateResponseData);
      autocomplete.ranked(term, null);
      expect(yam.request).toHaveBeenCalledWith({
        url: '/api/v1/autocomplete/ranked',
        method: 'GET',
        data: {'prefix':term,'models' :'user:3,group:2'},
        success: translateResponseData
      });
    });

    it('passes the correct argument for setting max user results to yam.request', function(){
      var term = 'foobar';
      var translateResponseData = jasmine.createSpy('translateResponseData');
      var autocomplete = Scheddo.YammerApi.autocomplete({});
      spyOn(autocomplete, 'translateResponseData').andReturn(translateResponseData);
      autocomplete.ranked(term, null, 99);
      expect(yam.request).toHaveBeenCalledWith({
        url: '/api/v1/autocomplete/ranked',
        method: 'GET',
        data: {'prefix':term,'models' :'user:99,group:2'},
        success: translateResponseData
      });
    });
  });

  describe('translateResponseData', function(){
    it('returns a function that translates Yammer data', function(){
      var api = Scheddo.YammerApi;
      var returnValue = api.autocomplete({}).translateResponseData('', function(){ });
      expect(typeof returnValue).toBe('function');
    });

    describe('the functnion returned by translateResponseData', function(){
      setupTranslator = function(){
        translator = jasmine.createSpyObj('translator',
          ['translateUsers', 'translateGroups', 'translateEmail']);
        translator.translateUsers.andReturn([]);
        translator.translateGroups.andReturn([]);
        translator.translateEmail.andReturn([]);
        return translator;
      };

      it('transforms user data', function(){
        var translator = setupTranslator();
        var api = Scheddo.YammerApi;
        var yammerData = {
          'user': [
            {
              data: 'user data'
            }
          ]
        };

        api.autocomplete(translator).translateResponseData('', function(param){ })(yammerData);
        expect(translator.translateUsers).toHaveBeenCalledWith(yammerData['user']);
      });

      it('transforms group data', function(){
        var translator = setupTranslator();
        var api = Scheddo.YammerApi;
        var yammerData = {
          'group': [
            {
              data: 'group data'
            }
          ]
        };

        api.autocomplete(translator).translateResponseData('', function(param){ })(yammerData);
        expect(translator.translateGroups).toHaveBeenCalledWith(yammerData['group']);
      });

      it('transforms email data', function(){
        var translator = setupTranslator();
        var api = Scheddo.YammerApi;

        api.autocomplete(translator).translateResponseData('term', function(param){ })({});
        expect(translator.translateEmail).toHaveBeenCalledWith('term');
      });

      it('concatenates the users, groups and email', function(){
        var translator = setupTranslator();
        translator.translateUsers.andReturn(['user']);
        translator.translateGroups.andReturn(['group']);
        translator.translateEmail.andReturn('email');
        var api = Scheddo.YammerApi;
        var response = jasmine.createSpy(response);

        api.autocomplete(translator).translateResponseData('term', response)({});

        expect(response).toHaveBeenCalledWith(['user', 'group', 'email']);
      });
    });
  });
});
