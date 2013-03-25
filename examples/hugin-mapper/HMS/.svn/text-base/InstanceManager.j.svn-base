@import "../ICON/LOArray.j"

@implementation InstanceManager : CPObject {
  LOArray instances;
  CPDictionary instance_info;
  ICONHub hub;
  
  @outlet CPCollectionView instance_list;
}

- (void)awakeFromCib
{
  instance_info = [[CPArray alloc] init];
  [instance_list setContent:instance_info];
  [instance_list setAutoresizingMask:CPViewWidthSizable];
  [instance_list setMinItemSize:CPSizeMake(
    [instance_list boundsSize].width,30)];
  [instance_list setMaxItemSize:CPSizeMake(
    [instance_list boundsSize].width,30)];
  [instance_list setSelectable:YES];
  [instance_list setDelegate:self];
}

- (void)setICONHub:(ICONHub)in_hub
{
  hub = in_hub;
  if([hub cluster] == 0){
    instances = 
      [hub liveObjectForPath:"cluster" factory:
        [[LOArrayFactory alloc] initWithFactory:
          [[LOJSONFactory alloc] init]]];
//    [hub dump];
//    [instances requestNotification:"add_object"
//           target:self selector:@selector(event:newInstance:)];
    var instances = [[instances activeObjects] objectEnumerator];
    var instance;
    while(instance = [instances nextObject]){
      [self event:"add_object" newInstance:instance];
    }
  }
}

- (id)event:(CPString)event newInstance:(LOJSON)instance
{
  var iobj = [instance object];
  for(i = 0; i < [instance_info count]; i++){
    //Public instances that we belong to will be duped.
    if([instance_info objectAtIndex:i].id == iobj.id){ return; }
  }
  [instance_info addObject:iobj];
  [instance_list reloadContent];
}

- (IBAction)deleteInstance:(id)sender
{
  CPLog("Would delete instance");
}

- (IBAction)createInstance:(id)sender
{
  CPLog("Would create instance");
}

- (IBAction)inviteToInstance:(id)sender
{
  CPLog("Would invite to instance");
}

- (IBAction)enterInstance:(id)sender
{
  var indexes = [instance_list selectionIndexes];
  if([indexes count] < 1) { 
    CPLog("Can't enter unselected instance; Bug Oliver to grey out buttons when nothing's selected.");
    return;
  }
  
  var clusterInfo = [instance_info objectAtIndex:[indexes firstIndex]];
  CPLog("Entering instance #%d: '%@'", clusterInfo.id, clusterInfo.name);
  [hub setCluster:clusterInfo.id];
}

@end

@implementation IMSelection : CPView {
  id instance_defn;
  CPTextField title_view;
}

- (void)setRepresentedObject:(LOJSON)in_instance_defn
{
  instance_defn = in_instance_defn;
  if(title_view == nil){
    title_view = [[CPTextField alloc] initWithFrame:CPRectInset([self bounds], 5, 5)];
    [self addSubview:title_view];
  }
  
  CPLog("Created: %@ : %@", instance_defn.name, CPStringFromRect([self bounds]));
  [title_view setStringValue:instance_defn.name];
  [title_view sizeToFit];
}

- (void)setSelected:(BOOL)isSelected
{
  [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

@end