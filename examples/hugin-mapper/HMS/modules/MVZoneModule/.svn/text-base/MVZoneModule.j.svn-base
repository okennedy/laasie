// Zones : spell areas and measurement.
// 
// Zone Types (definition.type)
//   (colors are always specified as hex codes)
// rectangle: { color, size, origin }
//   The upper left square in the zone is indicated by origin
//   size is a CPSize measured in squares (and must be >= (1,1))
// d20circle : { color, radius, origin }
//   (a d20 3.5 rules circle)
//   The center of the circle is the UL corner of the point indicated by origin
//   radius is in squares (and must be >= 1)
// d20cone : { color, origin, radius, direction, [offset] }
//   (a d20 3.5 rules cone)
//   The origin of the cone is the UL corner of the point indicated by origin
//   radius is in squares (and must be >= 1)
//   direction is an integer from 0 to 7 (inclusive)
//     0:  Directed to the upper right
//     1:  Directed right
//     2:  Directed to the lower right
//     3:  Directed down
//     4:  Directed to the lower left
//     5:  Directed left
//     6:  Directed to the upper left
//     7:  Directed up
//   Cones with a radius < 3, facing in a non-diagonal direction actually come
//     in two variants: offset up/left, or down/right.  This is because for 
//     these small sizes, the narrowest point of the cone is actually a single
//     square, and occupies one of the two adjacent to the origin point. If 
//     offset is true, the down/right option is taken.
// line : { color, origin, offset }
//   origin and offset are specified as CPPoints in squares

@import "../../../ICON/ICONObjectList.j"

var MVZoneActiveZoneType = "line";

@import "MVZoneTypeSetting.j"
@import "MVZone.j"
@import "MVZoneSharingPanel.j"

KAPPA=4.0 * ((SQRT2 - 1.0) / 3.0); //hack to get around a bug in AppKit;

@implementation MVZoneModule : CPView
{
  MapView mv;
  ICONObjectList zones;
  MVZone current_shape;
  CPString current_type;
  CPView zone_setting_view;
  MVZoneSharingPanel sharing_panel;
  MVZoneSharingSetting zone_sharing;
  CPColor active_color;
  int current_scale;
}

+ (CPString)activeZoneType
{
  return MVZoneActiveZoneType;
}
+ (void)setActiveZoneType:(CPString)activeZoneType
{
  MVZoneActiveZoneType = activeZoneType;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super initWithFrame:CPRectMakeZero()]){
    mv = in_mv;
    zones = nil;
    current_shape = nil;
    current_scale = 0;
    
    zone_sharing = [[MVZoneShareSetting alloc] initWithZoneModule:self];
    [zone_sharing setEnabled:NO];
    
    zone_setting_view = [MVSettingManager settingFrame];
    [zone_setting_view addSetting:[[MVZoneTypeSetting alloc] init]];
    [zone_setting_view addSetting:[MVSettingManagerColor colorSetting]];
    [zone_setting_view addSetting:zone_sharing];
    
    [MVSettingManagerColor monitorWithTarget:self 
                           selector:@selector(selectColor:)];

    sharing_panel = 
      [[MVZoneSharingPanel alloc] initWithOrigin:CPPointMake(200,200)
                                  zoneModule:self];
    
    [[CPNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(toolChanged:)
        name:[MVToolManager toolChangeNotification]
        object:nil];
  }
  return self;
}

- (void)toolChanged:(CPNotification)notification
{
  if([[[[notification userInfo] 
      objectForKey:"OLD_TOOL"] 
        name] isEqualToString:"Zone"]){
    [zone_sharing setEnabled:NO];
    [current_shape zoneDeleted];
    current_shape = nil;
  }
}

- (void)selectColor:(CPColor)in_color
{
  active_color = in_color
  [current_shape setColor:active_color];
}

- (void)mvSetICONHub:(ICON)icon_hub
{
  zones = 
    [[ICONObjectList alloc] 
      initForHub:icon_hub
      path:"zones"
      constructorTarget:self
      constructorSelector:@selector(makeZone:definition:)
      updateSelector:nil
      deleteSelector:@selector(zoneDeleted)
      commitSelector:@selector(zoneDeleted)];
  [icon_hub registerForUpdatesToPath:[icon_hub path]+"/zones"
            target:sharing_panel
            selector:@selector(setZones:)];
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{
  [self setFrameSize:[mv displayFrame].size];
  var scale = [mv gridSize];
  var z_iter = [zones objectEnumerator], z;
  while(z = [z_iter nextObject]){
    if(scale != current_scale){ [z resize]; }
    [z reposition];
  }
  current_scale = scale;
}

- (CPString)description
{
  return "MVZoneModule";
}

- (id)mvModuleInfo
{
  return { 
    view : self,
    menu : {
      Windows : {
        Zones : {
          action : @selector(makeKeyAndOrderFront:),
          target : sharing_panel
        }
      }
    },
    tools : {
      General : { 
        Zone : { 
          image : 
            [[CPImage alloc] initWithContentsOfFile:"Resources/applications-engineering.png"],
          mouseDownSel : @selector(zoneMouseDown:),
          mouseDragSel : @selector(zoneMouseDrag:),
          mouseUpSel   : @selector(zoneMouseUp:),
          toolView     : zone_setting_view
        }
      }
    }
  }
}

- (void)setting:(CPString)setting updatedValue:v
{
  if([setting isEqualToString:"ZONE_TYPE"]){
    current_type = v;
  } else {
    CPLog("Unknown setting : %@", setting);
  }
}

- (void)zoneMouseDown:(CPPoint)pt
{
  var origin_pt;
  [zone_sharing setEnabled:NO];
  [current_shape removeFromSuperview];
  switch(MVZoneActiveZoneType){
    case "d20circle":
    case "d20cone":
      origin_pt = CPPointMake(Math.floor(pt.x+0.5), Math.floor(pt.y+0.5)); break;
    default:
      origin_pt = CPPointMake(Math.floor(pt.x), Math.floor(pt.y)); break;
  }
  current_shape = [self makeZone:"<active zone>"
                        definition:{ type : MVZoneActiveZoneType,
                                     origin : origin_pt,
                                     color : [active_color hexString]}];
}

- (void)zoneMouseDrag:(CPPoint)pt
{
  [current_shape dragToPoint:pt];
  //CPPointMake(Math.floor(pt.x), Math.floor(pt.y))];
}

- (void)zoneMouseUp:(CPPoint)pt
{
  [zone_sharing setEnabled:YES];
}

- (MapView)mapview
{
  return mv;
}

- (CPSize)squareSize
{
  return [mv pixelSizeFromSize:CPSizeMake(1,1)];
}

- (MVZone)makeZone:(CPString)key definition:definition
{
  var zone = nil;
  switch(definition.type){
    case "rectangle":
      zone = [MVRectangleZone alloc]; break;
    case "d20circle":
      zone = [MVD20CircleZone alloc]; break;
    case "d20cone":
      zone = [MVD20ConeZone alloc]; break;
    case "line":
      zone = [MVLineZone alloc]; break;
    default:      
      CPLog("Unknown Zone Type: %@", definition.type);
  }
  if(zone){
    zone = [zone initWithKey:key 
                 definition:definition 
                 zoneModule:self];
    [self addSubview:zone];
  }
  return zone;
}

- (void)setHighlight:(CPString)zone_id
{
  var z_iter = [zones objectEnumerator], z;
  while(z = [z_iter nextObject]){
    [z setHighlighted:NO];
  }
  [[zones objectForKey:zone_id] setHighlighted:YES];
}

- (void)shareCurrentZoneWithName:(CPString)name
{
  var definition = [current_shape definition];
  definition.name = name;
  [zones insertNativeObject:current_shape value:definition];
  [current_shape removeFromSuperview];
  [sharing_panel makeKeyAndOrderFront:self];
}

- (void)deleteSharedZone:(CPString)zone_id
{
  [zones deleteObjectForKey:zone_id];
}

+ (CPString)humanName
{
  return "Measurement Tool"
}

+ (CPView)settingsView
{
  var settings = [[MVModuleManagerSettingPanel alloc] init];
  [settings addAnnotation:"The measurement module installs the measurement tool, which can be used to measure out lines, bursts, and cones.  Once a particular shape has been measured out, it may be shared with other users."];
  return settings;
}

+ (int)loadOrder
{
  return 51;// we want to load just after the grid/whiteboard modules
}

@end
