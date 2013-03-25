@import "MVBackdrop.j"
@import "MVBackdropList.j"
@import "MVBackdropEditor.j"
@import "../../../ICON/ICONObjectList.j"
@import "../../../ICON/ICONTableViewManager.j"

@implementation MVBackdropModule : CPObject
{
  MapView mv;
  MVBackdrop test;
  
  MVBackdropList backdrop_list_panel;
  ICONObjectList backdrops;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super init]){
    mv = in_mv;
    
    backdrop_view = [[CPView alloc] initWithFrame:CPRectMakeZero()];

    backdrop_list_panel = [[MVBackdropList alloc] initWithBackdropModule:self];
  }
  return self;
}

- (id)instantiateBackdrop:(CPString)internal_name serialized:(id)serialized
{
  var backdrop = [[MVBackdrop alloc] initWithSerialized:serialized];
  [backdrop setInternalName:internal_name];
  [backdrop setDelegate:self];
  [self backdropMoved:backdrop];
  [backdrop_view addSubview:[backdrop view]];
  return backdrop;
}

- (void)backdropMoved:(id)backdrop
{
  var new_loc = [mv pixelRectFromRect:[backdrop position]];
  [[backdrop view] setFrame:new_loc];
}

- (void)backdropDeleted:(id)backdrop
{
  [[backdrop view] removeFromSuperview];
  [backdrop_view display];
}

- (void)mvSetICONHub:(ICON)icon
{
  [backdrop_list_panel setICON:icon];
  backdrops = 
    [[ICONObjectList alloc] 
      initForHub:icon
      path:"backdrops"
      constructorTarget:self
      constructorSelector:@selector(instantiateBackdrop:serialized:)
      updateSelector:@selector(update:)
      deleteSelector:@selector(delete)
      commitSelector:@selector(delete)];
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{
  var frame = [mv displayFrame];
  frame.origin = CPPointMake(0,0);
  [backdrop_view setFrame:frame];
  [backdrop_view display];
  [backdrops each:function(backdrop){
    [self backdropMoved:backdrop];
  }];
}

- (void)backdropEditorSaved:(MVBackdropEditor)ed
{
  if([ed internalName]){
    [backdrops updateKey:[ed internalName] value:[ed serialized]];
  } else {
    [backdrops asynchInsertObject:[ed serialized]];
    [ed performClose:self];
  }
}

- (void)deleteBackdrop:(CPString)key
{
  [backdrops deleteObjectForKey:key];
}

- (CPString)description
{
  return "MVBackdropModule"
}

- (id)mvModuleInfo
{
  return {
    view : backdrop_view,
    menu : {
      Windows : { 
        Backdrops : {
          action : @selector(makeKeyAndOrderFront:),
          target : backdrop_list_panel
        }
      }
    }
  }
}

- (IBAction)deleteButton:(id)sender
{
  
}

- (IBAction)createButton:(id)sender
{
  
}

- (IBAction)bdlistDoubleClick:(id)sender
{
  
}

+ (CPString)humanName
{
  return "Backdrop Images"
}

+ (CPView)settingsView
{
  var settings = [[MVModuleManagerSettingPanel alloc] init];
  [settings addAnnotation:"The backdrop module allows you to import image files into Hugin as non-interactable backdrops.  It is specifically designed for use with maps, and allows users to precisely fit map images to Hugin's grid.  Backdrop management is provided through the Backdrops menu item."];
  return settings;
}

@end