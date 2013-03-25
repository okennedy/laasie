@import "../HMS/mapview/MVModuleManager.j"

@implementation InstanceEditor : CPObject
{
  @outlet CPWindow editor_window;
  @outlet CPTabView setting_tabs;
  
  @outlet CPTableView global_users;
  @outlet CPTableView instance_users;
  @outlet CPTableView admin_users;
  
  @outlet CPTextField search_box;

  @outlet CPButton promote_global;
  @outlet CPButton promote_instance;
  @outlet CPButton demote_instance;
  @outlet CPButton demote_admin;
  
  @outlet CPButton public_instance;
  
  @outlet CPTextField instance_name;
  @outlet CPTextField instance_key;
  @outlet CPTextField instance_image;
  @outlet CPImageView image_well;
  
  @outlet CPTextField status;

  InstanceUserList global_list;
  InstanceUserList instance_list;
  InstanceUserList admin_list;
  
  MVModuleManager modules;

  ICON icon;
  BOOL valid_image;
  BOOL save_on_validate;
  BOOL instance_is_new;
}

- (id)initWithIcon:(ICON)in_icon instance:(CPString)in_name
{
  if(self = [super init]){
    if([icon username] == "anonymous"){ return nil; }
  
    [[[CPCib alloc] initWithCibNamed:"InstanceEditor"
                              bundle:[CPBundle mainBundle]]
        instantiateCibWithOwner:self
        topLevelObjects:[CPArray array]];
    
    image_well = [[CPImageView alloc] initWithFrame:
      CPRectMake(20,20,100,86)];
    
    [image_well setBackgroundColor:[CPColor grayColor]];
    [image_well setImage:[CPImage imageNamed:"burst"]];
    [[editor_window contentView] addSubview:image_well];
    
    [status setTextColor:[CPColor whiteColor]];
    [status setBackgroundColor:[CPColor lightGrayColor]];
    
    icon = in_icon;
    valid_image = NO;
    save_on_validate = NO;

    global_list = 
      [[InstanceUserList alloc] initWithManagedTable:global_users];
    instance_list = 
      [[InstanceUserList alloc] initWithManagedTable:instance_users];
    admin_list = 
      [[InstanceUserList alloc] initWithManagedTable:admin_users];
    
    
    modules = [[MVModuleManager alloc] initWithICON:icon instance:in_name];
    [[setting_tabs tabViewItemAtIndex:
          [setting_tabs indexOfTabViewItemWithIdentifier:"modules"]]
        setView:[modules view]];
    [setting_tabs selectFirstTabViewItem:self];
//    [setting_tabs selectLastTabViewItem:self];
    
    [search_box setDelegate:global_list];
    
    [status setStringValue:""];
    
    [self setUserAdministrationEnabled:NO];
    [self refreshGlobalUsers];
  }
  return self;
}

- (id)initEditingInstance:(CPString)in_name
      icon:(ICON)in_icon
{
  if(self = [self initWithIcon:in_icon instance:in_name]){
    var instance_data = [icon getPath:"/instances/"+in_name+"/hugin_meta"];
    if(!instance_data) { CPLog("Inaccessable Instance Data"); return nil; }
    
    [instance_name  setStringValue:instance_data.name];
    [instance_key   setStringValue:in_name];
    [instance_image setStringValue:instance_data.icon.url];
    [public_instance setIntValue:instance_data.public_instance];
    [self setUserAdministrationEnabled:!instance_data.public_instance];
    instance_is_new = NO;
    
    [instance_key setEnabled:NO];
    
    if(instance_data.admins){
      for(i in instance_data.admins){
        if(i == "isa"){ continue; }
        var curr_user = 
          [global_list deleteUserWithNick:instance_data.admins[i]];
        [admin_list addUser:curr_user];
      }
    }
    if(instance_data.users){
      for(i in instance_data.users){
        if(i == "isa"){ continue; }
        var curr_user = 
          [global_list deleteUserWithNick:instance_data.users[i]];
        [instance_list addUser:curr_user];
      }
    }
    
    if(![admin_list userForNick:[icon username]]){
      CPLog("User %@ not in admin list", [icon username]); return nil;
    }
    
    [self tryValidateImage:self];
    [editor_window makeKeyAndOrderFront:self];
  }
  return self;
}

- (id)initEditingNewInstanceIcon:(ICON)in_icon
{
  if(self = [self initWithIcon:in_icon instance:nil]){
    var my_user = [global_list deleteUserWithNick:[icon username]];
    if(!my_user){ return nil; }
    [admin_list addUser:my_user];
    instance_is_new = YES;
    
    [editor_window makeKeyAndOrderFront:self];
  }
  return self;
}

- (void)refreshGlobalUsers
{
  var users = [icon getUserlist];
  [global_list setUsers:users];
}

- (void)log:(CPString)msg
{
  if(msg != ""){
    CPLog("Instance Editor: %@", msg);
  }
  [status setStringValue:msg];
}

- (void)setUserAdministrationEnabled:(BOOL)enabled
{
  [search_box setEnabled:enabled];
  [global_users setEnabled:enabled];
  [instance_users setEnabled:enabled];
  [admin_users setEnabled:enabled];
  [promote_global setEnabled:enabled];
  [promote_instance setEnabled:enabled];
  [demote_instance setEnabled:enabled];
  [demote_admin setEnabled:enabled];
}

- (IBAction)publicInstanceToggled:(id)sender
{
  [self setUserAdministrationEnabled:![sender intValue]];
}

- (IBAction)tryValidateImage:(id)sender
{
  [self log:"Validating Image..."];
  valid_image = NO;
  var image = 
    [[CPImage alloc] initWithContentsOfFile:[instance_image stringValue]];
  if([image loadStatus] != CPImageLoadStatusCompleted){
    [image setDelegate:self];
  } else {
    [self imageDidLoad:image];
  }
}

- (void)imageDidLoad:(CPImage)image
{
  [image_well setImage:image];  
  valid_image = YES;
  [self log:""];
  if(save_on_validate){
    save_on_validate = NO;
    [self performSave];
  }
}

- (void)imageDidError:(CPImage)image
{
  [self log:"ERROR: Invalid Image"];
  valid_image = NO;
  save_on_validate = NO;
}

- (void)imageDidAbort:(CPImage)image
{
  [self imageDidError:image];
}

- (IBAction)promoteGlobalUser:(id)sender
{
  var user = [global_list deleteSelectedUser];
  CPLog("Admitting %@", user.nick);
  [instance_list addUser:user];
}

- (IBAction)promoteInstanceUser:(id)sender
{
  var user = [instance_list deleteSelectedUser];
  CPLog("Promoting %@", user.nick);
  [admin_list addUser:user];
}

- (IBAction)demoteInstanceUser:(id)sender
{
  var user = [instance_list deleteSelectedUser];
  CPLog("Kicking out %@", user.nick);
  [global_list addUser:user];
}

- (IBAction)demoteAdministrator:(id)sender
{
  var user = [admin_list deleteSelectedUser];
  if(user.nick == [icon username]){
    var alert = 
      [CPAlert alertWithError:"You can not demote yourself"];
    [alert beginSheetModalForWindow:editor_window];
    [admin_list addUser:user];
    return;
  }
  CPLog("Demoting %@", user.nick);
  [instance_list addUser:user];
}

- (IBAction)saveButton:(id)sender
{
  if(valid_image){
    [self performSave];
  } else {
    save_on_validate = YES;
    [self tryValidateImage:sender];
  }
}

- (void)performSave
{
  var err = [self validateFields] || [modules validate];
  if(err) { [self log:"ERROR: "+err]; return; }
  
  var auth_meta = { "read" : {} };
  if([public_instance intValue]){
    auth_meta.read.anonymous = "YES";
  } else {
    var all_users = [[self users].concat([self admins]) objectEnumerator];
    var curr;
    while(curr = [all_users nextObject]){
      auth_meta.read[curr] = "YES";
    }
  }
  
  if(instance_is_new){
    [self log:"Validating short name with server..."];
    [icon writeToPath:("/instances/"+[instance_key stringValue]+"/.auth")
                 data:auth_meta
                 safe:NO
               target:self
              success:@selector(saveStageTwo:)
                 fail:@selector(invalidName:)];
  } else {
    [self log:"Saving Permissions..."];
    [icon writeToPath:("/instances/"+[instance_key stringValue]+"/.auth")
                 data:auth_meta];
    [self saveStageTwo:nil];
  }
}

- (void)saveStageTwo:(id)sender
{
  [self log:"Saving Instance..."];
  if(![public_instance intValue]){
    var auth_meta = { "read" : { "anonymous" : "YES" }, "write" : {} };
    var admin_users = [self admins];
    var all_users = [[self admins] objectEnumerator];
    var curr;
    while(curr = [all_users nextObject]){
      auth_meta.write[curr] = "YES";
    }
    [icon writeToPath:"/instances/"+[instance_key stringValue]+
                      "/hugin_meta/.auth"
                 data:auth_meta];
  }
  [icon writeToPath:"/instances/"+[instance_key stringValue]+"/hugin_meta"
               data:[self encoding]];
  [self log:"Done"];
  [editor_window close];
}

- (void)invalidName:(id)sender
{
  [self log:"ERROR: That short name is taken"];
}

- (id)imageInfo
{
  var img = [image_well image];
  if(img){
    return {
      url : [img filename],
      width : [img size].width,
      height : [img size].height
    };
  } else {  
    return {
      url : [instance_image stringValue],
      width : 100,
      height : 100
    };
  }
}

- (CPString)validateFields
{
  if([instance_name stringValue] == ""){ 
    return "You must name the instance"; 
  }
  if([instance_key stringValue] == ""){ 
    return "You must give instance a short name"; 
  }
  if([[[instance_key stringValue] componentsSeparatedByString:@" "] count] > 1){
    return "The short name can not contain spaces";
  }
  if([[[instance_key stringValue] componentsSeparatedByString:@"/"] count] > 1){
    return "The short name can not contain slashes";
  }
  if(instance_is_new && 
     [icon getPath:"/instances/"+[instance_key stringValue]]){
    return "That short name is already taken";
  }
  return nil;
}

- (id)users
{
  return [instance_list userNicks];
}

- (id)admins
{
  return [admin_list userNicks];
}

- (id)encoding
{
  return {
    name : [instance_name stringValue],
    icon : [self imageInfo],
    public_instance : [public_instance intValue],
    users : [self users],
    admins : [self admins],
    modules : [modules encoding]
  };
}

@end