@import "MVMiniModuleMini.j"
@import "MVMiniModuleProto.j"
@import "MVMiniModuleMiniOptions.j"
@import "../../OKConfirmationDialog.j"
@import "../../../ICON/ICONCollectionViewManager.j"

var MVMINI_DRAG_TYPE = "MVMINI_DRAG_TYPE";

@implementation MVMiniModule : CPView
{
  @outlet CPWindow mini_window;
  @outlet CPWindow add_proto_window;
  @outlet CPButton proto_add_button;
  @outlet CPTextField proto_url;
  @outlet CPImageView proto_preview;
  @outlet CPImageView proto_spinner;
  
  @outlet CPCollectionView proto_list;
  ICONCollectionViewManager proto_manager;
  
  @outlet MVMiniModuleMiniOptions mini_editor;
  
  CPDictionary map_minis;
  
  int mini_id;
  
  MapView mv;
  ICON icon_hub;
}

- (void)awakeFromCib
{
  mini_window 
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super initWithFrame:CPRectMakeZero()]){
    mv = in_mv;
    hub = nil;
    mini_id = 1;
    var mini_mod_cib = 
      [[CPCib alloc] initWithCibNamed:"MVMiniModule"
                     bundle:[CPBundle mainBundle]];
    [mini_mod_cib instantiateCibWithOwner:self 
                  topLevelObjects:[[CPArray alloc] init]];
    [proto_add_button setEnabled:NO];
    [proto_list setAutoresizingMask:CPViewWidthSizable];
    [proto_list setMinItemSize:CPSizeMake(60,60)];
    [proto_list setMaxItemSize:CPSizeMake(60,60)];
    [proto_list setSelectable:YES];
    [proto_list setDelegate:self];
    map_minis = [[CPDictionary alloc] init];
  }
  return self;
}

- (MapView)mapView
{
  return mv;
}

- (MVMiniModuleMiniOptions)miniEditor
{
  return mini_editor;
}

- (id)mapMinis
{
  return map_minis;
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{
  var mini, mini_iter = [map_minis objectEnumerator];
  
  while(mini = [mini_iter nextObject]){
    [mini updateView];
  }
  
  var frame = [mv displayFrame];
  frame.origin = CPPointMake(0,0);
  [self setFrame:frame];
}

- (ICONHub)iconHub
{
  return icon_hub;
}

- (void)mvSetICONHub:(ICONHub)in_icon_hub
{
  icon_hub = in_icon_hub;
  [icon_hub registerForUpdatesToPath:[icon_hub path]+"/minis"
            target:self
            selector:@selector(mapMinisUpdated:)];
  proto_manager = 
    [[ICONCollectionViewManager alloc]
      initWithCollectionView:proto_list
      path:[icon_hub path] + "/prototypes"
      icon:icon_hub];
}

- (id)mvModuleInfo
{
  return {
    view : self,
    menu : {
      Windows : { 
        Miniatures : {
          action : @selector(makeKeyAndOrderFront:),
          target : mini_window
        }
      },
      Cleanup : {
        "Clear Minis" : {
          action : @selector(promptClearMinis:),
          target : self
        }
      }
    },
    drags : [MVMINI_DRAG_TYPE]
  };
}

+ (id)miniDefnForImage:(CPImage)img name:(CPString)mini_name
{
  return {
    url    : [img filename],
    width  : [img size].width,
    height : [img size].height,
    name   : mini_name
  };
}

+ (CPImage)imageForMiniDefn:(id)mini_defn
{
  var size = CPSizeMake(mini_defn.width, mini_defn.height);
  var delta = 200;
  if((size.width < 200) && (size.height < 200)){
    var delta = 200 / Math.min(size.width, size.height);
    size.width *= delta;
    size.height *= delta;
  }
  var ret =
    [[CPImage alloc] 
      initByReferencingFile:mini_defn.url
      size:size];
  return ret;
}

- (void)mapMinisUpdated:(id)in_map_minis
{
  for(mini in in_map_minis){
    if([map_minis containsKey:mini]){
      if(in_map_minis[mini]){
        [[map_minis objectForKey:mini] setInternalDefinition:in_map_minis[mini]];
      }
      //updates
    } else {
      //insertions
      if(in_map_minis[mini]){
        var mini_manager =
          [[MVMiniModuleMini alloc] initWithMiniDefn:in_map_minis[mini]
                                    miniModule:self
                                    internalName:mini]
        [map_minis setObject:mini_manager forKey:mini];
        [self addSubview:[mini_manager view]];
      }
    }
  }
  if(in_map_minis == nil){
    CPLog("Delete All Minis")
    var old_iter = [map_minis objectEnumerator];
    var old;
    while(old = [old_iter nextObject]){
      [old localDeleteWithoutCleaning];
    }
    map_minis = [[CPDictionary alloc] init];
  } else {
    var old_iter = [map_minis objectEnumerator];
    var old;
    while(old = [old_iter nextObject]){
      var name = [old internalName];
      if(in_map_minis[name] == nil){
        [old localDelete];
      }
    }
  }
}

- (IBAction)promptClearMinis:(id)sender
{
  [OKConfirmationDialog confirmationDialog:"Really clear all minis?"
                        target:self
                        accept:@selector(clearMinis:)
                        reject:nil
                        modalOn:[mv window]];
}

- (IBAction)clearMinis:(id)sender
{
  [icon_hub deleteAtPath:[icon_hub path]+"/minis"];
}

- (void)saveMini:(MVMiniModuleMini)mini
{
  [icon_hub writeToPath:[icon_hub path]+"/minis/"+[mini internalName]
            data:[mini internalDefinition]];
}

- (IBAction)urlChanged:(id)sender
{
  [proto_add_button setEnabled:NO];
}

- (IBAction)previewProtoButton:(id)sender
{
  [proto_spinner setHidden:NO];
  var image = 
    [[CPImage alloc] initWithContentsOfFile:
      [proto_url stringValue]];
  [image setDelegate:self];
}

- (void)imageDidLoad:(CPImage)protoImage
{
  [proto_preview setImage:protoImage];
  [proto_spinner setHidden:YES];
  [proto_add_button setEnabled:YES];
}

- (void)imageDidError:(CPImage)protoImage
{
  [proto_spinner setHidden:YES]
  [proto_preview setImage:
    [[CPImage alloc] 
      initWithContentsOfFile:
        [[CPBundle mainBundle] resourcePath]+"/error.png" 
      size:CPSizeMake(40,40)]];
}

- (IBAction)addProtoButton:(id)sender
{
  [icon_hub appendToPath:[icon_hub path]+"/prototypes"
            data:[MVMiniModule miniDefnForImage:[proto_preview image] 
                               name:"Untitled Mini"]];
}

- (IBAction)deleteProtoButton:(id)sender
{
  var deleted_key = [proto_manager selectedKey];
  if(deleted_key){
    [[OKConfirmationDialog 
      confirmationDialog:"Delete mini?"
      target:self
      accept:@selector(deleteProtoAccept:)
      reject:nil
      modalOn:nil]
        setContext:deleted_key];
  } else {
    [[CPAlert alertWithMessageText:"No prototype mini is selected."
              defaultButton:"OK"
              alternateButton:nil
              otherButton:nil
              informativeTextWithFormat:nil] runModal];
  }
}

- (IBAction)deleteProtoAccept:(id)sender
{
  [icon_hub deleteAtPath:[icon_hub path]+"/prototypes/"+[sender context]];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [MVMINI_DRAG_TYPE];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  var proto_object = 
    [[[aCollectionView items] objectAtIndex:[indices firstIndex]] view];
  var ret = 
    [CPData dataWithJSONObject:[proto_object miniDefn]];
  return ret
}

- (void)mvModuleDragOperation:(CPDraggingInfo)event position:(CPPoint)pos
{
  var new_mini_defn = 
    [[[event draggingPasteboard] dataForType:MVMINI_DRAG_TYPE] JSONObject];
  
  new_mini_defn.x = pos.x - 0.5;
  new_mini_defn.y = pos.y - 0.5;
  new_mini_defn.name = "["+[icon_hub username]+" #"+mini_id+"]"; mini_id++;
  
//  CPLog("Creating mini: %@", [CPString JSONFromObject:new_mini_defn]);
  [icon_hub appendToPath:[icon_hub path]+"/minis"
            data:new_mini_defn];
}

@end

