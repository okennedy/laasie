
@implementation MVSettingManager : CPView
{
}

- (id)init
{
  if(self = [super initWithFrame:CPRectMake(0,0,200,0)]){
  }
  return self;
}

- (void)addSetting:(MVSettingManagerSetting)setting
{
  [setting setFrameOrigin:CPPointMake(0, [self frame].size.height)];
  [self setFrameSize:CPSizeMake(200, [self frame].size.height + 
                                     [setting frame].size.height)];
  [self addSubview:setting];
}

+ (void)monitorSetting:(CPString)setting
        target:(id)target
        selector:(id)selector
{
  return [[MVSettingManagerSettingMonitor alloc]
            initForSetting:setting
            target:target
            selector:selector];
}

+ (void)settingFrame
{
  return [[MVSettingManager alloc] init];
}

@end

@implementation MVSettingManagerSettingMonitor : CPObject
{
  CPInvocation invocation;
}

- (id)initForSetting:(CPString)setting
      target:(id)target 
      selector:(SEL)selector
{
  if(self = [super init]){
    invocation = [[CPInvocation alloc] initWithMethodSignature:nil];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [[CPNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(settingUpdateNotifier:)
        name:"MVSETTING_"+setting
        object:nil];
  }
  return self;
}

- (void)settingUpdateNotifier:(CPNotification)notification
{
  [self notify:[[notification userInfo] objectForKey:@"SETTING"]];
}

- (void)notify:(id)value
{
  [invocation setArgument:value atIndex:2];
  [invocation invoke];
}

@end

@implementation MVSettingManagerSetting : CPView
{
  CPString global_setting_name;
}

- (void)watchGlobalSetting:(CPString)in_global_setting_name;
{
  global_setting_name = "MVSETTING_"+in_global_setting_name;
  [[CPNotificationCenter defaultCenter]
      addObserver:self
      selector:@selector(settingUpdateNotifier:)
      name:global_setting_name
      object:nil];
}

- (void)settingUpdateNotifier:(CPNotification)notification
{
  [self settingUpdated:[[notification userInfo] objectForKey:@"SETTING"]];
}

- (void)updateGlobalSetting:(id)value
{
  [[CPNotificationCenter defaultCenter]
      postNotificationName:global_setting_name
      object:nil
      userInfo:[[CPDictionary alloc] 
          initWithObjects:[value]
          forKeys:["SETTING"]]];
}

- (void)settingUpdateNotifier:(CPNotification)notification
{
  [self settingUpdated:[[notification userInfo] objectForKey:@"SETTING"]];
}

- (int)addLabel:(CPString)text at:(CPPoint)pt
{
  var label = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
  [label setStringValue:text+":"];
  [label sizeToFit];
  [label setFrameOrigin:pt];
  [self addSubview:label];
  return [label frame].size.width+5+[label frame].origin.x;
}

@end

@import "MVSettingManagerThickness.j"
@import "MVSettingManagerColor.j"
