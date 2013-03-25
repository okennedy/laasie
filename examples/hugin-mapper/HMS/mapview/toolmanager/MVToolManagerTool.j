@implementation MVToolManagerTool : CPView
{
  CPString name;
  CPInvocation down;
  CPInvocation drag;
  CPInvocation up;
  CPImageView img;
  MVToolManager manager;
  BOOL active;
  CPMenuItem menu_item;
  CPView tool_settings_view;
}

- (id)initWithDefinition:(id)tool_defn name:(id)in_name module:(id)module manager:(MVToolManager)in_manager
{
  if(self = [super initWithFrame:CPRectMake(0,0,50,50)]){
    name = in_name;
    manager = in_manager;
    active = NO;
    
    img = [[CPImageView alloc] initWithFrame:CPRectInset([self frame], 4, 4)];
    [self addSubview:img];
    [img setImage:tool_defn.image];

    down = [[CPInvocation alloc] initWithMethodSignature:nil];
    [down setSelector:tool_defn.mouseDownSel];
    [down setTarget:module];

    drag = [[CPInvocation alloc] initWithMethodSignature:nil];
    [drag setSelector:tool_defn.mouseDragSel];
    [drag setTarget:module];

    up = [[CPInvocation alloc] initWithMethodSignature:nil];
    [up setSelector:tool_defn.mouseUpSel];
    [up setTarget:module];
    
    tool_settings_view = tool_defn.toolView;
  }
  return self;
}

- (CPView)toolView
{
  return tool_settings_view;
}

- (void)relayMouseDown:(CPPoint)point
{
  [down setArgument:point atIndex:2];
  [down invoke];
}
- (void)relayMouseDragged:(CPPoint)point
{
  [drag setArgument:point atIndex:2];
  [drag invoke];
}
- (void)relayMouseUp:(CPPoint)point
{
  [up setArgument:point atIndex:2];
  [up invoke];
}

- (CPMenuItem)menuItem
{
  if(!menu_item){
    menu_item = [[CPMenuItem alloc] initWithTitle:name 
                                    action:@selector(activate:) 
                                    keyEquivalent:nil];
    [menu_item setTarget:self];
  }
  return menu_item;
}

- (void)activate:(id)sender
{
  [manager activateTool:self];
}

- (void)setActive:(BOOL)new_active
{
  active = new_active;
  // we should do something here to highlight the selected tool in the menu
  // unfortunately [CPMenuItem setState:] seems to be ignored :(
  [self setNeedsDisplay:YES];
}

- (void)name
{
  return name;
}

- (self)drawRect:(CPRect)aRect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  CGContextSaveGState(context);
    CGContextSetStrokeColor(
      context, 
      active ? [CPColor redColor] : [CPColor grayColor]);
    CGContextSetLineWidth(1);
    CGContextStrokeRect(context, CPRectInset(aRect, 2, 2));
  CGContextRestoreGState(context);
}

- (void)mouseDown:(CPEvent)evt
{
  [manager activateTool:self];
}
@end