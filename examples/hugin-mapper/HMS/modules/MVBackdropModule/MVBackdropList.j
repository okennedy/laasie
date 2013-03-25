@implementation MVBackdropList : CPPanel
{
  ICONTableViewManager table_manager;

  CPTableView backdrop_table;
  CPScrollView backdrop_scroll;
  
  CPView new_backdrop_view;
  CPTextField new_backdrop_image;
  
  MVBackdropModule module;
}

- (id)initWithBackdropModule:(MVBackdropModule)in_module
{
  if(self = [super initWithContentRect:CPRectMake(300,100,400,400)
                             styleMask:CPTitledWindowMask |
                                       CPClosableWindowMask]){
    [self setTitle:@"Backdrops"];
    module = in_module;
    
    backdrop_table = 
      [[CPTableView alloc] initWithFrame:CPRectMakeZero()];
    [backdrop_table setTarget:self];
    [backdrop_table setDoubleAction:@selector(doEditBackdrop:)];
    backdrop_scroll = 
      [[CPScrollView alloc] initWithFrame:CPRectMake(0,0,400,350)];
    [backdrop_scroll setDocumentView:backdrop_table];
    [backdrop_scroll setAutohidesScrollers:YES];
    
    var tmp;
    
    tmp = [[CPTableColumn alloc] initWithIdentifier:"name"];
    [[tmp headerView] setStringValue:"Backdrop Name"];
    [tmp setMaxWidth:1000];
    [tmp setMinWidth:390];
    [backdrop_table addTableColumn:tmp];

    [[self contentView] addSubview:backdrop_scroll];
    
    tmp = [[CPButton alloc] initWithFrame:CPRectMake(115,360,130,24)];
    [tmp setTitle:"Delete Backdrop"];
    [tmp setAction:@selector(doDeleteBackdrop:)];
    [tmp setTarget:self];
    [[self contentView] addSubview:tmp];
    
    tmp = [[CPButton alloc] initWithFrame:CPRectMake(255,360,130,24)];
    [tmp setTitle:"Create Backdrop..."];
    [tmp setAction:@selector(doCreateBackdrop:)];
    [tmp setTarget:self];
    [[self contentView] addSubview:tmp];
    
    new_backdrop_image = 
      [[CPTextField alloc] initWithFrame:CPRectMake(10,10,300,28)];
    [new_backdrop_image setEditable:YES];
    [new_backdrop_image setPlaceholderString:"http://server.url/image.png"];
    [new_backdrop_image setBezeled:YES];
    [new_backdrop_image setAutoresizingMask:CPViewWidthSizable | 
                                            CPViewHeightSizable];
    new_backdrop_view = 
      [[CPView alloc] initWithFrame:CPRectMake(0,0,320,40)];
    [new_backdrop_view addSubview:new_backdrop_image];
    [new_backdrop_view setAutoresizesSubviews:YES];
    
  }
  return self;
}

- (void)setICON:(ICON)in_icon 
{
  table_manager = 
    [[ICONTableViewManager alloc] initWithTable:backdrop_table
                                  path:[in_icon path]+"/backdrops"
                                  icon:in_icon];
}

- (id)doDeleteBackdrop:(id)sender
{
  if([table_manager selectedKey] == nil){
    [[CPAlert alertWithMessageText:"No Backdrop Selected!" 
              defaultButton:"OK"
              alternateButton:nil
              otherButton:nil
              informativeTextWithFormat:nil] 
        beginSheetModalForWindow:self];
  } else {
    [module deleteBackdrop:[table_manager selectedKey]];
  }
}

- (void)doEditBackdrop:(id)sender
{
  if([table_manager selectedKey] == nil){
    [[CPAlert alertWithMessageText:"No Backdrop Selected!" 
              defaultButton:"OK"
              alternateButton:nil
              otherButton:nil
              informativeTextWithFormat:nil] 
        beginSheetModalForWindow:self];
  } else {
    var ed = [[MVBackdropEditor alloc] 
                initWithObject:[table_manager selectedDatum]
                internalName:[table_manager selectedKey]];
    [ed setDelegate:module];
    [ed makeKeyAndOrderFront:self];
  }
}

- (id)doCreateBackdrop:(id)sender
{
  var alert = 
    [CPAlert alertWithMessageText:"Select an Image to Load"
                                defaultButton:"Create"
                              alternateButton:"Cancel"
                                  otherButton:nil
                    informativeTextWithFormat:nil];
  [alert setAccessoryView:new_backdrop_view];
  [alert beginSheetModalForWindow:self
         modalDelegate:self
         didEndSelector:@selector(createBackdropConfirmed:)
         contextInfo:nil];
}

- (void)createBackdropConfirmed:(id)ctx
{
  var img = 
    [[CPImage alloc] initWithContentsOfFile:[new_backdrop_image stringValue]];
  var ed =
    [[MVBackdropEditor alloc] initWithImage:img];
  [ed setDelegate:module];
  [ed makeKeyAndOrderFront:self];
}


@end