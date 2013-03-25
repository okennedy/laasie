@import "mapview/MapView.j"

@implementation HuginController : CPObject
{
  @outlet MapView main_view;
  
  CPString short_name;
  ICON icon_hub;
}

- (id)initWithInstance:(CPString)in_short_name ICON:(ICON)in_icon_hub
{
  if(self = [super init]){
    short_name = in_short_name;
    icon_hub = in_icon_hub;
    var map_cib = 
      [[CPCib alloc] initWithCibNamed:"MVMapModule"
                     bundle:[CPBundle mainBundle]];
    [map_cib instantiateCibWithOwner:self 
                  topLevelObjects:[[CPArray alloc] init]];
    [main_view setICONHub:in_icon_hub];
    [main_view loadDefaultModules];
  }
  return self;
}

- (CPMenu)mainMenu
{
  return [main_view mainMenu];
}

- (CPView)mapView
{
  return main_view
}

@end