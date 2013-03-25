@import <Foundation/CPInvocation.j>

@implementation MVMenuManager : CPObject
{
  CPMenu main_menu;
  CPMenu tool_menu;
  CPMenu hugin_menu;
}

- (void)init
{
  if(self = [super init]){
    main_menu = [[CPApplication sharedApplication] mainMenu];
    hugin_menu = [[main_menu itemAtIndex:0] submenu];    
    
    var tool_item = [[CPMenuItem alloc] initWithTitle:"Tools" 
                                        action:nil keyEquivalent:nil];
    [main_menu addItem:tool_item];
    [tool_item setSubmenu:[[CPMenu alloc] initWithTitle:"Tools"]];
    tool_menu = [tool_item submenu];
  }
  return self;
}

- (void)awakeFromCib
{
  main_menu = [[CPApplication sharedApplication] mainMenu];
  
  while([main_menu numberOfItems] > 0){ 
    [main_menu removeItemAtIndex:0];
  }
  
  var tool_item = [[CPMenuItem alloc] initWithTitle:"Tools" 
                                      action:nil keyEquivalent:nil];
  [main_menu addItem:tool_item];
  [tool_item setSubmenu:[[CPMenu alloc] initWithTitle:"Tools"]];
  tool_menu = [tool_item submenu];
}

- (void)installModule:(id)module menus:(id)menu_info
{
  for(var menu_name in menu_info){
    if(menu_name == "isa") { continue; }
    var sub_menu;
    switch(menu_name){
      case "General":
        sub_menu = hugin_menu;
        break; // use the main menu
      default:
        var sub_item = [main_menu itemWithTitle:menu_name];
        if(!sub_item){ 
          sub_item = [[CPMenuItem alloc] initWithTitle:menu_name
                                         action:nil
                                         keyEquivalent:nil];
          [main_menu addItem:sub_item];
          [sub_item setSubmenu:[[CPMenu alloc] initWithTitle:menu_name]];
        }
        sub_menu = [sub_item submenu];
        break;
    }
    for(var item_name in menu_info[menu_name]){
      if(item_name == "isa") { continue; }
      var item = [[CPMenuItem alloc] 
                    initWithTitle:item_name
                    action:menu_info[menu_name][item_name].action
                    keyEquivalent:nil];
      [item setTarget:menu_info[menu_name][item_name].target];
      [sub_menu addItem:item];
    }
  }
}

- (void)installTool:(MVToolManagerTool)tool
{
  [tool_menu addItem:[tool menuItem]];
}

- (void)mainMenu
{
  return main_menu;
}

@end