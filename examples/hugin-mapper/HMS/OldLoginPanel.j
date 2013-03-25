
ICON_SERVER="ICON/ICON.php";

@import "settings/InstanceInfoManager.j"
@import "settings/AccountManager.j"
@import "HuginController.j"


@implementation LoginPanel : CPObject
{
  @outlet CPTextField username;
  @outlet CPTextField password;
  @outlet CPSplitView splitView;
  @outlet CPTextField log;
  @outlet CPCollectionView cv;
  @outlet CPWindow main_window;
  
  @outlet CPApplication app;
  
  @outlet InstanceInfoManager iimanager;
  
  ICON iconHub;
  CPArray instance_list;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
}

- (void)awakeFromCib
{
  var main_menu = [[CPMenu alloc] init];
  [main_menu _setMenuName:@"CPMainMenu"];
  [CPMenu setMenuBarVisible:YES];

  CPLog("Awake From CIB");

  if(HUGIN_JUMP_TO_INSTANCE) { [self loginButton:self]; }  

  [log setStringValue:""];
  [self closePanel];

    
  [cv setAutoresizingMask:CPViewHeightSizable];
  [cv setMinItemSize:CPSizeMake(290,300)];
  [cv setMaxItemSize:CPSizeMake(290,300)];
  [cv setSelectable:YES];
  
  //[self loadInstance:"beyond_ragnarok"];
}

- (void)closePanel
{
  if([splitView window]){
    var frame = [splitView frame];
    var wframe = [[splitView window] frame];
    [splitView setFrame:
      CPRectMake(
        frame.origin.x,
        (wframe.size.height/2)-58,
        frame.size.width,
        116+20
      )] ;
  }
}

- (void)openPanel
{
  if([splitView window]){
    var frame = [splitView frame];
    var wframe = [[splitView window] frame];
    [splitView setFrame:
      CPRectMake(
        frame.origin.x,
        16,
        frame.size.width,
        wframe.size.height-32
      )];
  }
}

- (void)loadInstance:(CPString)short_name
{
  [iconHub setDelegate:HMSController];
  [iconHub moveToPath:"/instances/"+short_name];
  var HMSController = 
    [[HuginController alloc] initWithInstance:short_name ICON:iconHub];
  [[HMSController mapView] setFrameOrigin:CPPointMake(0,0)];
  [[HMSController mapView] setFrameSize:[main_window frame].size];
  
  
  [[main_window contentView] replaceSubview:splitView 
                             with:[HMSController mapView]];
}

- (void)updateInstanceList:(id)list
{
  instance_list = [CPArray array];
  var i;
  for(i in list){
    if(i != "isa"){
      if(list[i].hugin_meta){
        [instance_list addObject:{ "short_name" : i, "data": list[i].hugin_meta}]
      } else {
        CPLog("Invalid Hugin Instance: %@ = %@", i, [CPString JSONFromObject:list[i]]);
      }
    }
  }
//  CPLog("%d instances found", [instance_list count]);
  [cv setContent:instance_list];
}

- (IBAction)loginButton:(id)sender
{
  var u = [username stringValue];
  if(u == ""){ u = "anonymous"; }
  
  iconHub = [[ICON alloc] initWithServer:ICON_SERVER
                          login:u
                          password:[password stringValue]
                          path:"instances"];
  [iconHub setDelegate:self];
}

- (IBAction)leaveButton:(id)sender
{
  CPLog("Would leave");
}

- (IBAction)createButton:(id)sender
{
  [iimanager createInstanceOnHub:iconHub];
}

- (id)selectedInstance
{
  var selected = [cv selectionIndexes];
  if([selected count] == 0){
    [log setStringValue:"You must select an instance first"];
    return nil;
  } else {
    return [instance_list objectAtIndex:[selected firstIndex]];
  }
}

- (IBAction)manageButton:(id)sender
{
  var selected = [self selectedInstance];
  if(selected){
    [iimanager manageInstance:selected.short_name
               oldState:selected.data
               hub:iconHub];
  }
}

- (IBAction)joinButton:(id)sender
{
  [self loadInstance:([self selectedInstance].short_name)]
}

- (void)ICONLoginSuccess:(ICON)i
{
  [log setStringValue:"Connected"];
  [iconHub registerForUpdatesToPath:"instances"
           target:self selector:@selector(updateInstanceList:)];
  if(HUGIN_JUMP_TO_INSTANCE){
    CPLog("Login successful, loading jump instance %@", HUGIN_JUMP_TO_INSTANCE);
    var instance_iter = [instance_list objectEnumerator];
    var instance;
    while(instance = [instance_iter nextObject]){
      if(HUGIN_JUMP_TO_INSTANCE == instance.short_name){
        [self loadInstance:HUGIN_JUMP_TO_INSTANCE];
        HUGIN_JUMP_TO_INSTANCE = nil;
      }
    }
    if(instance == nil){
      [log setStringValue:"Unknown or inaccessible instance: "+
                          HUGIN_JUMP_TO_INSTANCE];
    }
    [self closePanel];
  } else {
    [self openPanel];
  }
}

- (void)ICONConnectionFailed:(ICON)i reason:(CPString)reason
{
  [log setStringValue:"Connection Failed: "+reason];
  [self closePanel];
}

- (void)ICONRequestFailed:(ICON)i reason:(CPString)reason
{
  [log setStringValue:"Disconnected: "+reason];
  [self closePanel];
}

@end

@implementation InstanceView : CPView
{
  id instance_meta;
  CPString short_name;
  CPImageView image_view;
  CPTextField text_view;
}

- (void)setRepresentedObject:(id)in_instance_meta
{
  instance_meta = in_instance_meta.data;
  short_name = in_instance_meta.short_name;
  if(image_view == nil){
    image_view = [[CPImageView alloc] initWithFrame:CPRectMakeZero()];
    [image_view setImageScaling:CPScaleProportionally];
    [image_view setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [self addSubview:image_view];
  }
  if(text_view == nil){
    text_view = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [self addSubview:text_view];
  }
  
  [text_view setStringValue:instance_meta.name];
  [text_view sizeToFit]
  [text_view setFrameOrigin:CPPointMake(150-[text_view frameSize].width/2,275)]
  
  var image_frame = CPRectInset([self bounds], 5, 5);
  image_frame.size.height -= 30;
  var size = CPSizeMake(instance_meta.icon.width, instance_meta.icon.height);
  if((size.width < 500) &&
     (size.height < 500)) {
    var delta = Math.min(500 / size.width, 
                         500 / size.height);
    size.width *= delta;
    size.height *= delta;
  }
  [image_view setFrame:image_frame];  
  [image_view setImage:[[CPImage alloc] 
      initByReferencingFile:instance_meta.icon.url
      size:size]];
}

- (void)setSelected:(BOOL)isSelected
{
  [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

@end