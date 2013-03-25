@implementation InstanceInfoManager : CPObject
{
  @outlet CPTextField long_name;
  @outlet CPTextField short_name;
  @outlet CPTextField icon_url;
  @outlet CPTextField user_list;

  @outlet CPTextField log;
  @outlet CPButton save_button;
  @outlet CPImageView image_view;
  @outlet CPWindow window;
  
  BOOL instance_is_new;
  CPImage image;
  ICON icon_hub;
}

- (void)lockFields
{
  [long_name setEditable:NO];
  [short_name setEditable:NO];
  [icon_url setEditable:NO];
  [user_list setEditable:NO];
}

- (void)unlockFields
{
  [long_name setEditable:YES];
  [short_name setEditable:instance_is_new];
  [icon_url setEditable:YES];
  [user_list setEditable:YES];
}

- (void)resetFields
{
  [log setStringValue:""];
  [long_name setStringValue:""];
  [short_name setStringValue:""];
  [icon_url setStringValue:""];
  [user_list setStringValue:""];
}

- (void)createInstanceOnHub:(ICON)in_icon_hub
{
  icon_hub = in_icon_hub;
  instance_is_new = YES;
  [save_button setTitle:"Create"];
  [short_name setEditable:YES];
  [self resetFields];
  [self unlockFields];
  [window makeKeyAndOrderFront:self];
}

- (void)manageInstance:(CPString)in_short_name
        oldState:(id)old_state
        hub:(ICON)in_icon_hub
{
  icon_hub = in_icon_hub;
  instance_is_new = NO;
  [save_button setTitle:"Save"];
  [self resetFields];
  [self unlockFields];
  [short_name setStringValue:in_short_name];
  [long_name setStringValue:old_state.name];
  [icon_url setStringValue:old_state.icon.url];
  [user_list setStringValue:old_state.userlist_hint];
  [self loadImage:self];
  [window makeKeyAndOrderFront:self];
}

- (IBAction)saveButton:(id)sender
{
  [self validateAndSave];
  CPLog("Save Button");
}

- (IBAction)loadImage:(id)sender
{
  image = [[CPImage alloc] initWithContentsOfFile:[icon_url stringValue]];
  [image_view setImage:image];
}

- (void)log:(CPString)msg
{
  CPLog("Instance Info: %@", msg);
  [log setStringValue:msg];
}

- (void)finalImageCheck
{
  if([image filename] == [icon_url stringValue]){
    if([image loadStatus] == CPImageLoadStatusCompleted){
      return true;
    } else {
      [image setDelegate:self];
      return false;
    }
  } else {
    image = [[CPImage alloc] initWithContentsOfFile:[icon_url stringValue]];
    [image setDelegate:self];
    [image_view setImage:image];
  }
}

- (void)imageDidLoad:(CPImage)i
{
  [self validateAndSave];
}

- (void)imageDidError:(CPImage)i
{
  [self unlockFields];
  [self log:"Error: Image URL is invalid"];
}

- (void)basePath
{
  return "/instances/"+[short_name stringValue]
}

- (void)validateAndSave
{
  CPLog("YOYOYO");
  [self lockFields];
  if([long_name stringValue] == ""){
    [self log:"Error: You must name the instance"];
    return;
  }
  if([short_name stringValue] == ""){
    [self log:"Error: You must select a short name for the instance"];
    return;
  }
  if([[[short_name stringValue] componentsSeparatedByString:@" "] count] > 1){
    [self log:"Error: Short name can not contain spaces"];
    return;
  }
  if([[[short_name stringValue] componentsSeparatedByString:@"/"] count] > 1){
    [self log:"Error: Short name can not contain slashes"];
    return;
  }
  if(instance_is_new){
    if([icon_hub getPath:"/instances/"+[short_name stringValue]] != nil){
      [self log:"Error: Short name already taken"];
      return;
    }
  }
  if(![self finalImageCheck]){
    [self log:"Validating Image URL..."];
    return;
  }
  
  var auth_meta = { "read" : {} };
  if([user_list stringValue] == ""){
    auth_meta.read = { "anonymous" : "YES" }
  } else {
    var users = [[user_list stringValue] componentsSeparatedByString:","];
    if(![users containsObject:[icon_hub username]]){
      // the user management interface is kinda shitty atm.  There's a 
      // cleaner way to do this, but for now at least, keep the user from
      // doing something stupid.
      [user_list setStringValue:[user_list stringValue]+","+[icon_hub username]];
      [users addObject:[icon_hub username]];
    }
    users = [users objectEnumerator];
    var u;
    while(u = [users nextObject]){
      auth_meta.read[u] = "YES";
    }
  }
  
  if(instance_is_new){
    [self log:"Validating short name..."];
    [icon_hub writeToPath:("/instances/"+[short_name stringValue]+"/.auth")
              data:auth_meta
              safe:NO
              target:self
              success:@selector(finishSave:)
              fail:@selector(invalidName:)];
  } 
  else {
    [self log:"Saving ACL..."];
    [icon_hub writeToPath:("/instances/"+[short_name stringValue]+"/.auth")
              data:auth_meta];
    [self finishSave:nil];
  }
}

- (void)finishSave:(id)response
{
  [self log:"Saving..."];
  
  var image_size = [image size];
  var instance_meta = {
    "name" : [long_name stringValue],
    "icon" : {
      "url" : [image filename],
      "width" : image_size.width,
      "height" : image_size.height
    },
    "userlist_hint" : [user_list stringValue]
  }
  [icon_hub writeToPath:[self basePath]+"/hugin_meta"
            data:instance_meta];
  [window performClose:self];
}

- (void)invalidName:(id)response
{
  if(response.reason == "File Exists"){
    [self log:"Error: Short name already taken"];
  } else {
    [self log:"Error: "+response.reason];
  }
  [self unlockFields];
}


@end