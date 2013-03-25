@import <Foundation/CPInvocation.j>

@import "MVToolManagerTool.j"
@import "MVToolManagerPanel.j"

@implementation MVToolManager : CPObject
{
  CPDictionary tools;
  MVToolManagerTool active_tool;
  @outlet MapView mv;
  @outlet MVMenuManager menu;
}

- (void)initWithMapView:(MapView)in_mv menuManager:(MVMenuManager)in_menu
{
  if(self = [super init]){
    mv = in_mv;
    menu = in_menu;
    [self awakeFromCib];
  }
  return self;
}

- (void)awakeFromCib
{
  tools = [[CPDictionary alloc] init];
  active_tool = nil;
}

- (void)installModule:(id)module tools:(id)tool_info
{
  for(var cat in tool_info){
    for(var tool in tool_info[cat]){
      [self installTool:tool_info[cat][tool]
            name:tool
            category:cat
            module:module];
    }
  }
}

- (MVToolManagerPanel)panelForCategory:(CPString)cat_name
{
  var cat;
  if(!(cat = [tools objectForKey:cat_name])){
    cat = [[MVToolManagerPanel alloc] initWithName:cat_name];
    [tools setObject:cat forKey:cat_name];
    var menu_info = [];
    cat_name = [cat name]; // some special cases do some renaming
    menu_info[cat_name] = {
      action : @selector(makeKeyAndOrderFront:),
      target : cat
    };
    [menu installModule:self menus:{ Windows : menu_info }];
  }
  return cat;
}

- (void)installTool:(id)tool_defn 
        name:(CPString)tool_name 
        category:(id)cat_name 
        module:(id)module
{
  var cat = [self panelForCategory:cat_name];
  var tool = 
    [[MVToolManagerTool alloc] initWithDefinition:tool_defn 
                               name:tool_name
                               module:module
                               manager:self];
  [menu installTool:tool];
  [cat addTool:tool];
  [cat makeKeyAndOrderFront:self];
  if(active_tool == nil){
    [self activateTool:tool];
  }
}

+ (CPString)toolChangeNotification
{
  return "MAPVIEW_TOOL_CHANGE";
}

- (void)activateTool:(CPToolManagerTool)tool
{
  if(active_tool != nil){
    [active_tool setActive:NO];
  }
  var old_tool = active_tool;
  active_tool = tool;
  [[self panelForCategory:"General"] setToolView:[active_tool toolView]];
  [active_tool setActive:YES];
  [[CPNotificationCenter defaultCenter]
      postNotificationName:[MVToolManager toolChangeNotification]
      object:nil
      userInfo:[[CPDictionary alloc] 
          initWithObjects:[old_tool, active_tool]
          forKeys:["OLD_TOOL", "NEW_TOOL"]]];
}

- (MVToolManagerTool)activeTool
{
  return active_tool;
}
@end

