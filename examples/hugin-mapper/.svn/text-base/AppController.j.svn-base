@import "Login/LoginPanel.j"
@import "Login/InstancePicker.j"
@import "HMS/mapview/MapView.j"

HUGIN_USE_HISTORY_HACK = NO;

@implementation MapViewManager : CPObject
{
  MapView mv;
  ICON icon;
  id delegate;
}

- (id)initWithIcon:(ICON)in_icon delegate:(id)in_delegate
{
  if(self = [super init]){
    icon = in_icon;
    delegate = in_delegate;
    mv = [[MapView alloc] init];
    [mv setICONHub:icon];
  }
  return self;
}

- (void)loadMenuItems
{
  main_menu = [[CPApplication sharedApplication] mainMenu];
  hugin_menu = [[main_menu itemAtIndex:0] submenu];
  [hugin_menu addItem:[CPMenuItem separatorItem]];
  [MVModuleManager loadModulesForMapView:mv
                                fromICON:icon];  
//  [hugin_menu addItem:[CPMenuItem separatorItem]];
//  var quit_item = 
//    [[CPMenuItem alloc] initWithTitle:"Return to Instances"
//                          action:@selector(quitInstance:)
//                   keyEquivalent:nil];
//  [quit_item setTarget:delegate];
//  [hugin_menu addItem:quit_item];
}

- (CPView)view
{
  return mv;
}

- (void)abort
{
  
}

@end

@implementation AppController : CPObject
{
  @outlet CPWindow    theWindow;
  @outlet CPView      default_view;
  @outlet CPWindow    about_hugin;
  
  ICON icon;
  
  CPObject curr_state_manager;
}

- (void)switchToState:(id)new_state_manager
{
  if(!new_state_manager) { return; }
  [curr_state_manager abort];
  var view = [new_state_manager view] || default_view;
  [theWindow setContentView:view];
  
  var main_menu = [[CPApplication sharedApplication] mainMenu];
  while([main_menu numberOfItems] > 1){
    [main_menu removeItemAtIndex:1];
  }
  var hugin_menu = [[main_menu itemAtIndex:0] submenu];
  while([hugin_menu numberOfItems] > 1){
    [hugin_menu removeItemAtIndex:1];
  }
  [new_state_manager loadMenuItems]; 
  
  curr_state_manager = new_state_manager;
}

- (void)switchToLoginForced:(BOOL)force
{
  CPLog("Switching to Login Panel");
  [self switchToState:
    [LoginPanel startLoginProcessWithDelegate:self force:force]]
}

- (void)switchToInstancesPush:(BOOL)push
{
  if(icon){
//    if(HUGIN_USE_HISTORY_HACK && push && history){
//      history.replaceState({mode:"instance_list"},
//                           "Hugin Map System Instance List",
//                           "");
//    }
    CPLog("Switching to Instances Panel");
    [self switchToState:
      [InstancePicker selectInstanceWithDelegate:self icon:icon]];
  } else {
    CPLog("ERROR: Switching to instances without an active ICON client");
    CPLog("Falling back to login screen");
    [self switchToLoginForced:YES];
  }
}

- (void)awakeFromCib
{
  [theWindow setFullPlatformWindow:YES];
  window.onpopstate = function(event){
    [self popState:event];
  }
  [self switchToLoginForced:NO];
}

///////// Step 1, try to log in

- (void)performLogout
{
  [LoginPanel clearStoredCredentials];
  [self switchToLoginForced:NO];
}

- (void)loginFailed:(CPString)reason
{
  var alert = 
    [CPAlert alertWithError:
      [CPString stringWithFormat:"Could not connect to server: %@", reason]];
  [alert beginSheetModalForWindow:
    [[CPApplication sharedApplication] mainWindow]];
  [self switchToLoginForced:YES];
}

///////// Step 2, pick an instance to join

- (void)quitInstance:(id)sender
{
  [self switchToInstancesPush:NO];
}

- (void)loginSuccess:(ICON)in_icon
{
  CPLog("Logged in as %@", [in_icon username]);
  icon = in_icon;
  [self switchToInstancesPush:YES];
}

///////// Step 3, join the instance

- (void)joinInstance:(CPString)instance
{
  CPLog("Joining Instance %@", instance);
  if(history){
    if(HUGIN_USE_HISTORY_HACK){
      history.pushState({mode:"instance", instance:instance},
                        "Hugin Instance <"+instance+">",
                        "?instance="+instance);
    } else {
      history.replaceState({mode:"instance", instance:instance},
                           "Hugin Instance <"+instance+">",
                           "?instance="+instance);
    }
  }
  [icon setDelegate:nil];
  [icon moveToPath:"/instances/"+instance];
  CPLog("Switching to Map View");
  [self switchToState:[[MapViewManager alloc] initWithIcon:icon
                                                  delegate:self]];
}

///////// And to back up...

- (void)popState:(id)event
{
  if(event.state == null){
    [self switchToLoginForced:YES];
  } else switch(event.state.mode) {
    case "instance_list":
      [self switchToInstancesPush:NO];
      break;
      
    case undefined:
      CPLog("ERROR: Popped state into undefined mode.  Falling back to login");
      [self switchToLoginForced:YES];
      break;
  }
}

@end
