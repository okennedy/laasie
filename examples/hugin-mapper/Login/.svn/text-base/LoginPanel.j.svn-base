ICON_SERVER="ICON/ICON.php";

@import "../ICON/ICON.j"
@import "CreateAccountManager.j"

@implementation LoginAttempt : CPObject
{
  CPString username;
  CPString password;
  id delegate;
  ICON icon;
}

- (id)initWithUsername:in_username password:in_password delegate:in_delegate
{
  if(self = [super init]){
    username = in_username;
    password = in_password;
    delegate = in_delegate;
    if(username == ""){ username = "anonymous"; }
    icon = [[ICON alloc] initWithServer:ICON_SERVER
                         login:username
                         password:password
                         path:"/"];
    [icon setDelegate:self];
  }
  return self;
}

- (void)ICONConnectionFailed:(ICON)i reason:(CPString)reason
{
  [delegate loginFailed:reason];
}

- (void)ICONRequestFailed:(ICON)i reason:(CPString)reason
{
  [delegate loginFailed:reason];
}

- (void)ICONLoginSuccess:(ICON)i
{
  [delegate loginSuccess:icon];
}

@end

@implementation LoginPanel : CPObject 
{
  @outlet CPTextField username;
  @outlet CPTextField password;
  @outlet CPView view;
  @outlet CPCheckBox stay_logged_in;
  @outlet CPButton login;
  id delegate;
}

- (id)initWithDelegate:(id)in_delegate
{
  if(self = [super init]){
    [[[CPCib alloc] initWithCibNamed:"LoginPanel"
                              bundle:[CPBundle mainBundle]]
        instantiateCibWithOwner:self
        topLevelObjects:[CPArray array]];
    [password setSecure:YES];
    delegate = in_delegate;
  }
  return self;
}

- (IBAction)loginButton:(id)sender
{
  [login setEnabled:NO];
  [[LoginAttempt alloc] initWithUsername:[username stringValue]
                                password:[password stringValue]
                                delegate:self];
}

- (CPView)view
{
  return view;
}

- (void)loadMenuItems
{
  return nil;
}

- (void)abort
{
}

- (void)loginFailed:(CPString)reason
{
  [login setEnabled:YES];
  var alert = 
    [CPAlert alertWithError:
      [CPString stringWithFormat:"Could not login: %@", reason]];
  [alert beginSheetModalForWindow:
    [[CPApplication sharedApplication] mainWindow]];
}

- (void)loginSuccess:(ICON)icon
{
  [login setEnabled:YES];
  if([stay_logged_in intValue] && ([username stringValue] != "")){
    var defaults = [CPUserDefaults standardUserDefaults];
    [defaults setObject:[username stringValue] forKey:"HuginUsername"];
    [defaults setObject:[password stringValue] forKey:"HuginPassword"];
  }
  [delegate loginSuccess:icon];
}

+ (LoginPanel)startLoginProcessWithDelegate:(id)delegate force:(BOOL)force;
{
  if(!force){
    var defaults = [CPUserDefaults standardUserDefaults];
    var username = [defaults objectForKey:"HuginUsername"];
    var password = [defaults objectForKey:"HuginPassword"];
    if(username && (username != "")){
      CPLog("Found stored username '%@'.  Trying it.", username);
      [[LoginAttempt alloc] initWithUsername:username
                                    password:password
                                    delegate:delegate];
      return nil;
    }
  }
  return [[LoginPanel alloc] initWithDelegate:delegate];
}

+ (void)clearStoredCredentials
{
  var defaults = [CPUserDefaults standardUserDefaults];
  [defaults removeObjectForKey:"HuginUsername"];
  [defaults removeObjectForKey:"HuginPassword"];
}

@end

