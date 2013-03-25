@import "../../ICON/ICONTableViewManager.j"

@implementation MVInitiativeModule : CPObject {
  MapView mv;
  ICON icon;
  
  CPPanel init_window;
  CPTableView init_list;
  ICONTableViewManager init_data;
  
  CPTextField character;
  CPTextField init;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super init]){
    icon = nil;
    mv = in_mv;
    
    var tmp;
    init_window = 
      [[CPPanel alloc] initWithContentRect:CPRectMake(600,100,300,400) 
                       styleMask:CPTitledWindowMask |
                                 CPClosableWindowMask];
    [init_window setTitle:"Initiative"];
    
    var scroller = 
      [[CPScrollView alloc] initWithFrame:CPRectMake(10,10,280,270)];
    [scroller setHasHorizontalScroller:NO];
    [[init_window contentView] addSubview:scroller];

    init_list = 
      [[CPTableView alloc] initWithFrame:[scroller bounds]];
    tmp = [[CPTableColumn alloc] initWithIdentifier:"row"];
      [tmp setWidth:25]; 
      [[tmp headerView] setStringValue:"#"]; 
      [init_list addTableColumn:tmp];
    tmp = [[CPTableColumn alloc] initWithIdentifier:"user"];
      [tmp setWidth:170];
      [[tmp headerView] setStringValue:"Character"]; 
      [tmp setEditable:YES];
      [init_list addTableColumn:tmp];
    tmp = [[CPTableColumn alloc] initWithIdentifier:"mod"];
      [tmp setWidth:25];
      [[tmp headerView] setStringValue:"+"];
      //[tmp setEditable:YES];
      [init_list addTableColumn:tmp];
    tmp = [[CPTableColumn alloc] initWithIdentifier:"result"];
      [tmp setWidth:35];
      [[tmp headerView] setStringValue:"Init"];
      [tmp setEditable:YES];
      [init_list addTableColumn:tmp];
    [scroller setDocumentView:init_list];
    
    tmp = [[CPButton alloc] initWithFrame:CPRectMake(155,290,135,24)];
    [tmp setTitle:"Delete"];
    [tmp setTarget:self];
    [tmp setAction:@selector(deleteButton:)];
    [[init_window contentView] addSubview:tmp];

    tmp = [[CPTextField alloc] initWithFrame:CPRectMake(10,335,70,18)];
    [tmp setStringValue:"Character:"];
    [[init_window contentView] addSubview:tmp];
    
    character = [[CPTextField alloc] initWithFrame:CPRectMake(80,335,210,18)];
    [character setBackgroundColor:[CPColor whiteColor]];
    [character setEditable:YES];
    [[init_window contentView] addSubview:character];
    
    tmp = [[CPTextField alloc] initWithFrame:CPRectMake(10,364,70,18)];
    [tmp setStringValue:"Modifier:"];
    [[init_window contentView] addSubview:tmp];
    
    init = [[CPTextField alloc] initWithFrame:CPRectMake(80,364,50,18)];
    [init setBackgroundColor:[CPColor whiteColor]];
    [init setEditable:YES];
    [init setStringValue:"0"];
    [[init_window contentView] addSubview:init];
    
    tmp = [[CPButton alloc] initWithFrame:CPRectMake(150,360,130,24)];
    [tmp setTitle:"Roll Initiative"];
    [tmp setTarget:self];
    [tmp setAction:@selector(rollButton:)];
    [[init_window contentView] addSubview:tmp];
    
  }
  return self;
}

- (CPString)description
{
  return "Initiative Roller"
}

- (void)mvSetICONHub:(ICON)in_icon
{
  icon = in_icon;
  init_data = [[ICONTableViewManager alloc] 
                initWithTable:init_list
                path:[icon path]+"/initiative/rolls"
                icon:icon];
  [init_data setSortFunction: function(a,b,ctx) {
                  // 1 = b > a / -1 = b < a
                  if((a.result*1) > (b.result*1))      { return -1; }
                  else if((a.result*1) < (b.result*1)) { return  1; }
                  else                                 { return  0; }
                }
              context:nil];
  [character setStringValue:[icon username]];
}

- (void)deleteButton:(id)sender
{
  var data = [init_data selectedDatum];
  if(data){
    var alert = 
      [CPAlert alertWithMessageText:("Delete character '"+data.user+"'?")
               defaultButton:"No"
               alternateButton:"Yes"
               otherButton:nil
               informativeTextWithFormat:nil];
    [alert setDelegate:self];
    [alert runModal];
  } else {
    [[CPAlert alertWithMessageText:("No character selected")
              defaultButton:"OK"
              alternateButton:nil
              otherButton:nil
              informativeTextWithFormat:nil] runModal];
  }
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)code
{
  if(code){
    var key = [init_data selectedKey];
    if(key){
      [icon deleteAtPath:[icon path]+"/initiative/rolls/"+key];
    }
  }
}

- (void)rollButton:(id)sender
{
  var roll = Math.ceil(Math.random()*20);
  [icon appendToPath:[icon path]+"/initiative/rolls"
        data:{ "user"   : [character stringValue],
               "mod"    : [init intValue],
               "roll"   : roll,
               "result" : roll + [init intValue] }];
}

- (void)mvModuleInfo
{
  return {
    menu : {
      Windows : {
        "Initiative" : {
          target : init_window,
          action : @selector(makeKeyAndOrderFront:)
        }
      }
    }
  };
}

+ (CPString)humanName
{
  return "Initiative Roller"
}

+ (CPView)settingsView
{
  var settings = [[MVModuleManagerSettingPanel alloc] init];
  [settings addAnnotation:"This module adds d20 style initiaitive rolling functionality.  The initiative roller can be accessed through the Windows menu."];
  return settings;
}

@end