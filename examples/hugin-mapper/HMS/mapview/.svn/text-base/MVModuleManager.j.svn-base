@implementation MVModuleManagerSettingPanel : CPView
{
  CPArray settings;
  id validator;
  CPArray views;
}

- (id)init
{
  if(self = [super initWithFrame:CPRectMakeZero()]){
    [self setAutoresizingMask: CPViewWidthSizable | CPViewMaxYMargin];
    settings = [[CPArray alloc] init];
    next_height = 20;
    validator = nil;
  }
  return self;
}

- (CPRect)newSettingFrame:(int)height
{
  next_height += 20+height
  [self setFrameSize:CPSizeMake(340, next_height + 20)];
  return CPRectMake(20, next_height - (20+height), 300, height);
}

- (void)setValidator:(id)in_validator
{
  validator = in_validator;
}

- (void)addStringSetting:(CPString)title 
        named:(CPString)name 
        defaultValue:(CPStringValue)defaultValue
{
  var new_control = [[CPTextField alloc] initWithFrame:[self newSettingFrame:30]];
  [new_control setBezelStyle:CPTextFieldSquareBezel];
  [new_control setBezeled:YES];
  [new_control setEditable:YES];
  [new_control setAutoresizingMask: CPViewWidthSizable | CPViewMaxYMargin];
  [new_control setPlaceholderString:"<"+title+">"];
  [self addSubview:new_control];

  var new_setting = {
    name : name,
    control : new_control,
    getter : @selector(stringValue),
    setter : @selector(setStringValue:),
    defaultValue : defaultValue
  };
  [settings addObject:new_setting];
}

- (void)addBooleanSetting:(CPString)title 
        named:(CPString)name
        defaultValue:(BOOL)defaultValue
{
  var new_control = [[CPCheckBox alloc] initWithFrame:[self newSettingFrame:30]];
  [new_control setAutoresizingMask: CPViewWidthSizable | CPViewMaxYMargin];
  [new_control setTitle:title];
  [self addSubview:new_control];
  
  var new_setting = {
    name : name,
    control : new_control,
    getter : @selector(intValue),
    setter : @selector(setIntValue:),
    defaultValue : defaultValue
  };
  [settings addObject:new_setting];
}

- (void)addAnnotation:(CPString)message
{
  var new_control = [[CPTextField alloc] initWithFrame:CPRectMake(20,0,300,0)];
  [new_control setAutoresizingMask: CPViewWidthSizable | CPViewMaxYMargin];
  [new_control setLineBreakMode:CPLineBreakByWordWrapping];
  [new_control setStringValue:message];
  [new_control sizeToFit];
  [new_control setFrame:[self newSettingFrame:[new_control frameSize].height]];
  [self addSubview:new_control];
}

- (void)loadFromSettings:(id)in_settings
{
  var iter = [settings objectEnumerator];
  var s;
  while(s = [iter nextObject]){
    if(in_settings[s.name] != nil){
      var invocation = [CPInvocation invocationWithMethodSignature:nil];
      [invocation setTarget:s.control];
      [invocation setSelector:s.setter];
      [invocation setArgument:in_settings[s.name] atIndex:2];
      [invocation invoke];
    }
  }
}

- (CPString)validate
{
  if(validator) { return validator([self encoding]); }
  else { return nil; }
}

- (id)encoding
{
  var iter = [settings objectEnumerator];
  var s;
  var ret = {};
  
  while(s = [iter nextObject]){
    var invocation = [CPInvocation invocationWithMethodSignature:nil];
    [invocation setTarget:s.control];
    [invocation setSelector:s.getter];
    [invocation invoke];
    ret[s.name] = [invocation returnValue];
  }
  
  return ret;
}

@end

@implementation MVModuleManager : CPObject
{
  @outlet CPView manager_view;
  @outlet CPTableView module_list;
  @outlet CPScrollView module_settings;
  
  ICON icon;
  CPString instance;
  CPArray modules;
}

- (id)initWithICON:(ICON)in_icon instance:(CPString)in_instance
{
  if(self = [super init]){
    icon = in_icon;
    instance = in_instance;
    [[[CPCib alloc] initWithCibNamed:"ModuleManager"
                          bundle:[CPBundle mainBundle]]
      instantiateCibWithOwner:self
      topLevelObjects:[CPArray array]];
    modules = [[CPArray alloc] init];
    var opt_modules = [MVModuleManager optionalModules];
    for(i in opt_modules){
      if(i == "isa") { continue; }
      var module = opt_modules[i].module
      var name = opt_modules[i].name
      var human_name = 
        [module respondsToSelector:@selector(humanName)] ?
          [module humanName] : name;
      if([module respondsToSelector:@selector(settingsView)]){
        var setting_view = [module settingsView];
        [modules addObject:{
          name : human_name,
          internal_name : name,
          module : module,
          settings : setting_view,
          active: ([setting_view validate] == nil) ? YES : NO
        }];
      } else {
        [modules addObject:{
          name : human_name,
          internal_name : name,
          module : module,
          settings : [[CPView alloc] initWithFrame:CPRectMakeZero()],
          active : YES
        }];
      }
    }
    if(instance){ [self reloadSettings]; }
    [module_list reloadData];
  }
  return self;
}

- (void)reloadSettings
{
  var iter = [modules objectEnumerator];
  var m;
  while(m = [iter nextObject]){
    var s = [icon getPath:
                "instances/"+instance+
                "/hugin_meta/modules/"+m.internal_name];
    if(s){
      if([m.settings respondsToSelector:@selector(loadFromSettings:)]){
        [m.settings loadFromSettings:s];
      }
      m.active = YES;
    } else {
      m.active = NO;
    }
  }
}

- (IBAction)selectModule:(id)sender
{
  var row = [module_list selectedRow];
  if(row < 0){
    [module_settings 
      setDocumentView:[[CPView alloc] initWithFrame:CPRectMakeZero()]];
  } else {
    var module = [modules objectAtIndex:row];
    [module_settings
      setDocumentView:module.settings];
  }
}

- (id)encoding
{
  var encoding = {};
  var iter = [modules objectEnumerator];
  var m;
  while(m = [iter nextObject]){
    if(m.active){
      if([m.settings respondsToSelector:@selector(encoding)]){
        encoding[m.internal_name] = [m.settings encoding];
      } else {
        encoding[m.internal_name] = [];
      }
    }
  }
  return encoding;
}

- (CPString)validate
{
  var iter = [modules objectEnumerator];
  var m;
  while(m = [iter nextObject]){
    if(m.active){
      if([m.settings respondsToSelector:@selector(validate)]){
        var err = [m.settings validate];
        if(err){ 
          return [CPString stringWithFormat:
                    "Invalid Setting for the %@ module: %@",
                    m.name, err];
        }
      }
    }
  }
  return nil;
}

- (CPTabViewItem)view
{
  return manager_view
}

- (int)numberOfRowsInTableView:(CPTableView)sender
{
  return [modules count];
}

- (id)tableView:(CPTableView)sender objectValueForTableColumn:(CPTableColumn)col row:(int)row
{
  return [modules objectAtIndex:row][[col identifier]];
}

- (void)tableView:(CPTableView)sender setObjectValue:(id)val forTableColumn:(CPTableColumn)col row:(int)row
{
  if([col identifier] == "active"){
    [modules objectAtIndex:row].active = val;
  }
}

///////////////////////////////////

+ (id)optionalModules
{
  return [
    { name : "irc"     , module : MVIRCModule        },
    { name : "backdrop", module : MVBackdropModule   },
    { name : "zone"    , module : MVZoneModule       },
    { name : "save"    , module : MVSaveRestoreModule},
    { name : "init"    , module : MVInitiativeModule }
  ];
}

+ (id)requiredModules
{
  return [MVGridModule, MVWhiteboardModule, MVMiniModule];
}

////////////////////////////
// Module load orders
//
// 0  : Default load order.  All optional modules load here by default
// 50 : Grid module.  The grid module loads here.  Anything after this point
//      will not have the grid drawn over it.  Modules with custom tools should
//      have a higher load order so that their tools show up after the default
//      set of tools.

+ (void)loadModulesForMapView:(MapView)mv fromICON:(ICON)icon
{
  var required = [self requiredModules];
  var optional = [self optionalModules];
  var modulesToLoad = [[CPArray alloc] init];
  
  var settings = [icon getPath:[icon path]+"/hugin_meta/modules"];
  for(i in required){
    if(i == "isa"){ continue; }
    var module_class = required[i];
    [modulesToLoad addObject:{
      name         : i,
      module_class : module_class, 
      priority     : ([module_class respondsToSelector:@selector(loadOrder)] ?
                        [module_class loadOrder] : 50),
      settings     : {}
    }];
  }
  if(settings){
    for(i in optional){
      if(i == "isa"){ continue; }
      if(optional[i] && settings[optional[i].name]){
        var module_class = optional[i].module;
        [modulesToLoad addObject:{
          name         : optional[i].name,
          module_class : module_class, 
          priority  : ([module_class respondsToSelector:@selector(loadOrder)] ?
                          [module_class loadOrder] : 0),
          settings  : settings[optional[i].name]
        }];
      }
    }
  }
  
  var iter = [[modulesToLoad sortedArrayUsingFunction:function(a, b, ctx) {
    if(a.priority < b.priority) return -1
    else if(a.priority == b.priority) return 0
    else return 1;
  }] objectEnumerator];
  var module;
  
  while(module = [iter nextObject]){
    [mv tryLoadModuleClass:module.module_class settings:module.settings];
  }
  
  // The Mini Module gets special treatment.  Due to a bug in the way events
  // are handled, we need to make sure that the mini module is loaded last.
  [mv tryLoadModuleClass:MVMiniModule];
}


@end