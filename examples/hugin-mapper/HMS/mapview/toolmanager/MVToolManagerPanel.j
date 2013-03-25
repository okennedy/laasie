@implementation MVToolManagerPanel : CPPanel
{
  CPString name;
  CPArray tools;
  int width;
  CPView tool_view;
}

- (id)initWithName:(CPString)in_name
{
  if(self = [super initWithContentRect:CPRectMakeZero()
                   styleMask:CPTitledWindowMask]){
    width = 4;
    name = ([in_name isEqualToString:"General"] ? "Tools" : in_name);
    tools = [[CPArray alloc] init];
    [self setFloatingPanel:YES];
    [self setTitle:name];
    [self setFrameOrigin:CPPointMake(50,50)];
  }
  return self;
}

- (void)addTool:(MVToolMangerTool)tool
{
  [tools addObject:tool];
  [[self contentView] addSubview:tool];
  [self rebuildFrame];
}

- (void)rebuildFrame
{
  var iter = [tools objectEnumerator];
  var obj;
  [self setFrameSize:CPSizeMake(
    Math.min([tools count], width) * 50,
    Math.ceil(([tools count] * 1.0) / (width * 1.0)) * 50 + 26 +
    (tool_view ? [tool_view frame].size.height + 15 : 0)
  )];
//  CPLog("Rebuilding frame with tool_view size: %@",
//        (tool_view ? [tool_view frame].size.height : 0));
  var x = 0, y = 0;
  while(obj = [iter nextObject]){
    [obj setFrameOrigin:CPPointMake(x * 50, y * 50)];
    x++;
    if(x >= width) { y++; x = 0; }
  }
  y = y * 50 + ((x == 0) ? 0 : 50) + 10;
  if(tool_view){
    CPLog("Setting up toolview");
    [tool_view setFrame:CPRectMake(0, y, 
                                   [self frame].size.width,
                                   [tool_view frame].size.height)];
  }
}

- (void)setToolView:(CPView)in_tool_view
{
  [tool_view removeFromSuperview];
  tool_view = in_tool_view
  if(tool_view){
    [[self contentView] addSubview:tool_view];
  }
  [self rebuildFrame];
}

- (void)clearToolView
{
  [self setToolView:nil];
}

- (CPString)name
{
  return name;
}

@end
