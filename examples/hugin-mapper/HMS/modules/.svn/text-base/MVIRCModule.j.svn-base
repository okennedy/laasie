MVIRC_DEFAULT_WIDTH  = 600
MVIRC_DEFAULT_HEIGHT = 400
MVIRC_SERVER_URL = "http://odin.xthemage.net:1773"

@implementation MVIRCModule : CPPanel
{
  CPWebView web_view;
  BOOL chat_active;
  ICON icon;
  CPString server_url;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super initWithContentRect:CPMakeRect(320,50, 
                                                  MVIRC_DEFAULT_WIDTH,
                                                  MVIRC_DEFAULT_HEIGHT)
                   styleMask:CPTitledWindowMask |
                             CPClosableWindowMask |
                             CPResizableWindowMask]){
    [self setTitle:"Chat"];
    server_url = settings.url;
    CPLog("IRC Server URL is: %@", server_url);
    web_view = [[CPWebView alloc] initWithFrame:CPMakeRect(0,0,
                                                MVIRC_DEFAULT_WIDTH,
                                                MVIRC_DEFAULT_HEIGHT)];
    [web_view setAutoresizingMask:CPViewWidthSizable |
                                  CPViewHeightSizable];
    [[self contentView] addSubview:web_view];
    chat_active = NO;
  }
  return self;
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{

}

- (CPString)description
{
  return "Internet Relay Chat Module"
}

- (void)startChatting:(id)sender
{
  if(!chat_active){
    var username = [icon username];
    if(username == "anonymous"){
      username = "Hugin_User_.";
    }
    username = encodeURI(username);
    var instance = [[icon path] componentsSeparatedByString:"/"];
    instance = encodeURI([instance lastObject]);
    var real_url = [[server_url 
      stringByReplacingOccurrencesOfString:"%u" withString:username]
      stringByReplacingOccurrencesOfString:"%i" withString:instance];
    [web_view setMainFrameURL:real_url];
    chat_active = YES;
  }
  [self makeKeyAndOrderFront:sender];
}

- (void)mvSetICONHub:(ICON)in_icon_hub
{
  icon = in_icon_hub;
}

- (id)mvModuleInfo
{
  return {
    menu : {
      "Windows" : {
        "Chat" : {
          target: self,
          action : @selector(startChatting:)
        }
      }
    }
  };
}

+ (CPString)humanName
{
  return "Internet Relay Chat";
}

+ (CPView)settingsView
{
  var settings = [[MVModuleManagerSettingPanel alloc] init];
  [settings setValidator:function(s){
    if((s == nil) || (s.url == nil)){
      return nil;
    } else {
      if(s.url != ""){ return nil; }
      else { return "Please enter a Server URL"; }
    }
  }];
  [settings addStringSetting:"IRC Server"
            named:"url"
            defaultValue:""];
  [settings addAnnotation:"The IRC module allows you to vew an (externally served) web-based IRC (or other chat) client within a Hugin instance.  In order to use this module, you must first set up a web-based IRC client.  In the server name above, the following replacements will be performed\n  %u\tLogged in Username\n  %i  \tInstance name\n\nA list of web-based IRC clients may be found at\nhttp://www.irc-wiki.org/"];
  return settings;
}

@end