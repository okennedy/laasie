@implementation MVZoneSharingPanel : CPPanel {
  id zones;
  CPTableView zone_table;
  CPButton delete_btn;
  MVZoneModule zm;
}

- (id)initWithOrigin:(CPPoint)origin zoneModule:(MVZoneModule)in_zm
{
  if(self = [super 
              initWithContentRect:CPRectMake(origin.x, origin.y, 300, 275)
              styleMask:CPTitledWindowMask | CPClosableWindowMask]){
    [self setFloatingPanel:YES];
    [self setTitle:"Zone Management"];
    
    zm = in_zm;
    
    zones = [[CPArray alloc] init];
    var scroller = 
      [[CPScrollView alloc] initWithFrame:CPRectMake(10,10,280,220)];
    [scroller setHasHorizontalScroller:NO];
    [[self contentView] addSubview:scroller];

    zone_table = [[CPTableView alloc] initWithFrame:[scroller bounds]];
    [zone_table setDataSource:self];
    [zone_table setDelegate:self];
    [scroller setDocumentView:zone_table];
    
    var col = [[CPTableColumn alloc] initWithIdentifier:"NAME"];
    [[col headerView] setStringValue:"Name"];
    [col setWidth:280];
    [zone_table addTableColumn:col];
    
    delete_btn = [[CPButton alloc] initWithFrame:CPRectMake(190,240,100,24)];
    [delete_btn setTitle:"Delete Zone"];
    [delete_btn setTarget:self];
    [delete_btn setAction:@selector(doDelete:)];
    [[self contentView] addSubview:delete_btn];
  }
  return self;
}

- (void)setZones:(id)in_zones
{
  zones = [[CPArray alloc] init];
  for(var k in in_zones){
    if(in_zones[k]){
      [zones addObject:{ internal : k, name : in_zones[k].name }];
    }
  }
//  var height = Math.min(24*[zones count]+20, 240)
//  [self setFrameSize:CPSizeMake(300, height+60)];
//  [delete_btn setFrameOrigin:CPPointMake(190,height)];
  [zone_table selectColumnIndexes:[CPIndexSet indexSet] byExtendingSelection:NO];
  [zone_table reloadData];
}

- (int)numberOfRowsInTableView:(CPTableView)view
{
  return [zones count];
}

- (id)tableView:(CPTableView)view 
      objectValueForTableColumn:(CPTableViewColumn)col
      row:(int)row
{
  return zones[row].name;
//  return [CPString JSONFromObject:zones[row]];
}

- (void)tableViewSelectionDidChange:(CPTableView)view
{
  var selected = [zone_table selectedRow];
  if((selected >= 0) && (selected < [zones count])){
    [zm setHighlight:zones[selected].internal]
  } else {
    [zm setHighlight:nil];
  }
}

- (void)doDelete:(id)sender
{
  var selected = [zone_table selectedRow];
  if(selected >= 0){
    [zm deleteSharedZone:zones[[zone_table selectedRow]].internal];
  } else {
    alert("No zone is selected.");
  }
}
@end

@implementation MVZoneShareSetting : MVSettingManagerSetting
{
  CPTextField zone_name;
  CPButton share_button;
  MVZoneModule zm;
  int zone_name_id;
}

- (void)setEnabled:(BOOL)in_active
{
  if(in_active){
    [zone_name setStringValue:"Zone #"+zone_name_id];
  } else {
    [zone_name setStringValue:""];
  }
  [share_button setEnabled:in_active];
}

- (id)initWithZoneModule:(MVZoneModule)in_zm
{
  if(self = [super initWithFrame:CPRectMake(0,0, 200, 30)]){
    zm = in_zm;
    
    zone_name_id = 1;
    
    share_button = [[CPButton alloc] initWithFrame:CPRectMake(10,3,70,24)];
    [share_button setTitle:"Share:"];
    [share_button setTarget:self];
    [share_button setAction:@selector(doShare:)];
    [self addSubview:share_button];
    
    zone_name = [[CPTextField alloc] initWithFrame:CPRectMake(85,6,105,18)];
    [zone_name setPlaceholderString:"<No Zone Drawn>"];
    [zone_name setEditable:YES];
    [zone_name setBackgroundColor:[CPColor whiteColor]];
    [self addSubview:zone_name];
  }
  return self;
}

- (void)doShare:(id)sender
{
  [zm shareCurrentZoneWithName:[zone_name stringValue]];
  if([[zone_name stringValue] isEqualToString:"Zone #"+zone_name_id]){
    zone_name_id = (zone_name_id * 1) + 1;
  }
  [zone_name setStringValue:""];
}
@end
