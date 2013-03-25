@implementation MVToolManagerSetting : CPObject
{
  CPArray menus;
  CPArray buttons;
  CPString name;
  CPDictionary values;
  CPDictionary images;
  id target;
  id setting;
}

- (id)initWithModule:(id)in_target name:(CPString)in_name values:(id)in_values
{
  if(self = [super init]){
    target = in_target;
    name = in_name;
    values = [[CPDictionary alloc] init];
    setting = nil;
    
    for(var option in in_values){
      if(setting == nil){ setting = option; }
      [values setObject:in_values[option] forKey:option];
    }
    menus = [[CPArray alloc] init];
    buttons = [[CPArray alloc] init];
    [target setting:name updatedValue:[values objectForKey:setting]];
  }
  return self;
}

- (CPMenu)menu
{
  var menu = [[CPMenu alloc] initWithTitle:name];
  var item;
  var optionIter = [values keyEnumerator];
  var option;
  
  // workaround for Cappuccino's button grabbing the first item as the title
  [menu addItemWithTitle:"dummy" action:nil keyEquivalent:nil];
  while(option = [optionIter nextObject]){
    item = [[CPMenuItem alloc] initWithTitle:option 
                               action:@selector(selectItem:)
                               keyEquivalent:nil];
    [item setTarget:self];
    [item setRepresentedObject:[values objectForKey:option]]
    [menu addItem:item];
  }
  [menus addObject:menu];
  return menu;
}

- (CPPopUpButton)popUpButtonWithFrame:(CPRect)frame
{
  var button = [[CPPopUpButton alloc] initWithFrame:frame];
  [button setMenu:[self menu]];
  [button setPullsDown:YES];
  // +1 for the workaround
  [button setTitle:name + ": " + setting];
  [buttons addObject:button];
  return button;
}

- (void)updateTo:(CPString)in_setting value:(id)in_value
{
  var button, buttonIter = [buttons objectEnumerator];
  setting = in_setting;
  while(button = [buttonIter nextObject]){
    [button setTitle:name + ": " + in_setting];
  }
  [target setting:name updatedValue:in_value];  
}

- (void)selectByName:(CPString)elementName
{
  [self updateTo:elementName value:[values objectForKey:elementName]];
}

- (void)selectItem:(id)sender
{
  [self updateTo:[sender title] value:[sender representedObject]];
}

@end