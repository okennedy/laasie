@implementation MVSaveRestoreModule : CPObject {
  @outlet CPScrollView scroller;
  @outlet CPTableView table;
  @outlet CPWindow window;
  @outlet CPTextField save_name;
  ICON icon;
  ICONTableViewManager table_manager;
  CPArray save_paths;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super init]){
    save_paths = [[CPArray alloc] init]
    [self addSavePath:"minis" titled:"Miniatures"];
    [self addSavePath:"shapes" titled:"Map Whiteboard"];
    [self addSavePath:"zones" titled:"Shared Zones"];
    
    var cib_file = 
      [[CPCib alloc] initWithCibNamed:"MVSaveRestoreModule"
                     bundle:[CPBundle mainBundle]];
    [cib_file instantiateCibWithOwner:self 
              topLevelObjects:[[CPArray alloc] init]];
    
    table = [[CPTableView alloc] initWithFrame:CPRectMakeZero()];
    [scroller setDocumentView:table];
    
    var tmp;
    tmp = [[CPTableColumn alloc] initWithIdentifier:"name"];
    [table addTableColumn:tmp];
    [[tmp headerView] setStringValue:"Save Name"];
    [tmp setWidth:[table frameSize].width];
  }
  return self;
}

- (void)addSavePath:(CPString)path titled:(CPString)title
{
  [save_paths addObject:{ "path" : path, "title" : title } ];
}

- (void)mvSetICONHub:(ICON)in_icon
{
  icon = in_icon
  table_manager = 
    [[ICONTableViewManager alloc] 
      initWithTable:table
      path:[icon path]+"/saves"
      icon:icon];
}

- (CPString)description
{
  return "Save/Restore Module";
}

- (id)mvModuleInfo
{
  return {
    menu : {
      Windows : {
        "Save/Restore" : {
          target : window,
          action : @selector(makeKeyAndOrderFront:)
        }
      }
    }
  };
}

- (IBAction)doDelete:(id)sender
{
  var key = [table_manager selectedKey];
  var save = [table_manager selectedDatum];
  if(key){
    [[OKConfirmationDialog
      confirmationDialog:"Delete save "+save.name+"?"
      target:self
      accept:@selector(doDeleteConfirm:)
      reject:nil] setContext:key];
  } else {
    [[CPAlert alertWithError:"No save is selected"] runModal];
  }
}

- (IBAction)doDeleteConfirm:(OKConfirmationDialog)sender
{
  [icon deleteAtPath:[icon path]+"/saves/"+[sender context]];
}

- (IBAction)doSave:(id)sender
{
  var iter = [save_paths objectEnumerator];
  var path;
  var save_obj = {
    name : [save_name stringValue],
    contents : nil,
    data : {}
  };
  if(![save_obj.name isEqualToString:""]){
    while(path = [iter nextObject]){
      if(save_obj.contents) {
        save_obj.contents = path.title;
      } else {
        save_obj.contents += ", "+path.title;
      }
      save_obj.data[path.path] = {
        title : path.title,
        path : path.path,
        data : [icon getPath:[icon path]+"/"+path.path]
      }
    }
    [icon appendToPath:[icon path]+"/saves" 
          data:save_obj];
  } else {
    [[CPAlert alertWithError:"Give the save file a title first"] runModal];
  }
}

- (IBAction)doLoad:(id)sender
{
  var save = [table_manager selectedDatum];
  if(save){
    [[OKConfirmationDialog
      confirmationDialog:"Really load save "+save.name+"?"
      target:self
      accept:@selector(doLoadConfirm:)
      reject:nil] setContext:save];
  } else {
    [[CPAlert alertWithError:"No save is selected"] runModal];
  }
}

- (IBAction)doLoadConfirm:(OKConfirmationDialog)sender
{
  var save_obj = [sender context];
  if(save_obj) {
    for(var i in save_obj.data){
      if(save_obj.data[i].data){
        CPLog("Restoring %@ : %@", 
                [icon path] + "/" + save_obj.data[i].path,
                [CPString JSONFromObject:save_obj.data[i].data]);
        [icon writeToPath:[icon path] + "/" + save_obj.data[i].path
              data:save_obj.data[i].data];
      } else {
        CPLog("Nothing to restore at %@",
                [icon path] + "/" + save_obj.data[i].path);
 
      }
    }
  }
}

+ (CPString)humanName
{
  return "Save/Restore"
}

+ (CPView)settingsView
{
  var settings = [[MVModuleManagerSettingPanel alloc] init];
  [settings addAnnotation:"This module adds save/restore functionality for Hugin maps.  This functionality may be accessed through the Save/Load item in the Window menu."];
  return settings;
}

@end