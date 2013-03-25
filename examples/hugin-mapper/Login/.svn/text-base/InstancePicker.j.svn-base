@import "InstanceUserList.j"
@import "InstanceEditor.j"
@import "EditAccountManager.j"

@implementation InstancePicker : CPObject
{
  @outlet CPTableView instances;
  @outlet CPView view;
  @outlet EditAccountManager account_editor;

  ICON icon;
  CPArray instance_info;
  id delegate;
}

- (id)initWithDelegate:(id)in_delegate icon:(ICON)in_icon
{
  if(self = [super init]){
    [[[CPCib alloc] initWithCibNamed:"InstancePicker"
                              bundle:[CPBundle mainBundle]]
        instantiateCibWithOwner:self
        topLevelObjects:[CPArray array]];
    [instances setRowHeight:160];
    delegate = in_delegate;
    icon = in_icon;
    [self refresh:self];
    [instances setDataSource:self];
  }
  return self;
}

- (IBAction)refresh:(id)sender
{
  instance_info = [[CPArray alloc] init];
  var full_info = [icon getPath:"/instances/"]
  for(i in full_info){
    if(i == 'isa'){ continue; }
    [instance_info addObject:{identifier : i , data: full_info[i].hugin_meta}];
  }
  [instances reloadData];
}

- (IBAction)createInstance:(id)sender
{
  if(![[InstanceEditor alloc] initEditingNewInstanceIcon:icon]){
    var alert = 
      [CPAlert alertWithError:
        "You must be logged in as a user to create instances"];
    [alert beginSheetModalForWindow:
      [[CPApplication sharedApplication] mainWindow]];
  }
}

- (IBAction)editInstance:(id)sender
{
  var row = [instances selectedRow];
  if(row < 0){
    var alert = 
      [CPAlert alertWithError:"You must first select an instance to edit"];
    [alert beginSheetModalForWindow:
      [[CPApplication sharedApplication] mainWindow]];
    return;
  }
  if(![[InstanceEditor alloc] initEditingInstance:instance_info[row].identifier
                                             icon:icon]){
    var alert = 
      [CPAlert alertWithError:
        "You are not authorized to edit that instance"];
    [alert beginSheetModalForWindow:
      [[CPApplication sharedApplication] mainWindow]];
  }
}

- (IBAction)joinInstance:(id)sender
{
  var row = [instances selectedRow];
  if(row < 0){
    var alert = 
      [CPAlert alertWithError:"You must first select an instance to join"];
    [alert beginSheetModalForWindow:
      [[CPApplication sharedApplication] mainWindow]];
    return;
  }
  [delegate joinInstance:instance_info[row].identifier];
}

- (IBAction)startLogout:(id)sender
{
  var alert = [CPAlert alertWithMessageText:("Log out '"+[icon username]+"'?")
                              defaultButton:"No"
                            alternateButton:"Yes"
                                otherButton:nil
                  informativeTextWithFormat:nil];
  [alert beginSheetModalForWindow:[[CPApplication sharedApplication] mainWindow]
                    modalDelegate:self
                   didEndSelector:@selector(finishLogout:code:ctx:)
                      contextInfo:nil];
}

- (IBAction)finishLogout:(id)sender code:(int)returnCode ctx:(id)ctx
{
  if(returnCode){
    [delegate performLogout];
  }
}

- (IBAction)manageAccount:(id)sender
{
  [account_editor editAccountWithIcon:icon];
}

- (int)numberOfRowsInTableView:(CPTableView)tv
{
  return [instance_info count];
}

- (id)tableView:(CPTableView)tv 
      objectValueForTableColumn:(CPTableColumn)col
      row:(int)row
{
  var i = [instance_info objectAtIndex:row];
  switch([col identifier]){
    case "image":
      if(i.data && i.data.icon){
        return [[CPImage alloc] initByReferencingFile:i.data.icon.url
                                                 size:i.data.icon];
      } else {
        CPLog("Missing icon for instance %@", i.identifier);
      }
      break;
    
    case "title":
      return i.data.name;
    
    default:
      CPLog("Request for unknown column %d: %@, %@", row, [col identifier], 
            [CPString JSONFromObject:i]);
      return nil;
  }
}

- (CPView)view
{
  return view;
}

- (void)loadMenuItems
{
  var main_menu = [[CPApplication sharedApplication] mainMenu];
  var hugin_menu = [[main_menu itemAtIndex:0] submenu];
  var item;
  item = [[CPMenuItem alloc] initWithTitle:"Manage Account..."
                                    action:@selector(manageAccount:)
                             keyEquivalent:nil];
  [item setTarget:self];
  [hugin_menu addItem:item];
  
  [hugin_menu addItem:[CPMenuItem separatorItem]];
  item = [[CPMenuItem alloc] initWithTitle:"Logout"
                                    action:@selector(startLogout:)
                             keyEquivalent:nil];
  [item setTarget:self];
  [hugin_menu addItem:item];
}

- (void)abort
{

}

+ selectInstanceWithDelegate:(id)delegate icon:(ICON)icon
{
  if(HUGIN_JUMP_TO_INSTANCE){
    CPLog("Found Jump Instance %@", HUGIN_JUMP_TO_INSTANCE);
    if([icon getPath:"/instances/"+HUGIN_JUMP_TO_INSTANCE+"/hugin_meta"]){
      [delegate joinInstance:HUGIN_JUMP_TO_INSTANCE];
      return nil;
    } else {
      CPLog("Error: Jump Instance does not exist (or is not accessible)!");
    }
  }
//  [[InstanceEditor alloc] initEditingInstance:"test" icon:icon];
  return [[InstancePicker alloc] initWithDelegate:delegate icon:icon];
}

@end