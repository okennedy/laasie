@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

var MVSettingManagerColorActiveColor = [CPColor blackColor];

@implementation MVSettingManagerColor : MVSettingManagerSetting
{
  CPArray color_buttons;
}

- (void)addColorButton:(CPColor)color at:(CPPoint)pt
{
  var t;
  t = [[MVSettingManagerColorButton alloc]
          initWithColor:color target:self];
  [color_buttons addObject:t];
  [t setFrameOrigin:pt];
  [self addSubview:t];
}

- (id)init
{
  if(self = [super initWithFrame:CPRectMake(0, 0, 200, 60)]){
    [self watchGlobalSetting:"DRAW_COLOR"];
    color_buttons = [[CPArray alloc] init];
    var y = 0;
    var init_x = [self addLabel:"Color" at:CPPointMake(5, y+5)]+25;
    var x = init_x;
    [self addColorButton:[CPColor blackColor]  at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor grayColor]   at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor redColor]    at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor greenColor]  at:CPPointMake(x,y)]; x += 30;
    y += 30; x = init_x;
    [self addColorButton:[CPColor blueColor]   at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor brownColor]  at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor yellowColor] at:CPPointMake(x,y)]; x += 30;
    [self addColorButton:[CPColor orangeColor] at:CPPointMake(x,y)]; x += 30;
    [self settingUpdated:MVSettingManagerColorActiveColor];
  }
  return self;
}

- (void)selectColor:(CPColor)color
{
  [self updateGlobalSetting:color];
  MVSettingManagerColorActiveColor = color;
}

- (void)settingUpdated:(CPColor)color
{
  var cb_iter = [color_buttons objectEnumerator];
  var cb;
  while(cb = [cb_iter nextObject]){
    [cb setActive:([cb color] == color)];
  }
}

+ (void)monitorWithTarget:target
        selector:selector
{
  var monitor =
    [MVSettingManager monitorSetting:"DRAW_COLOR"
                      target:target
                      selector:selector];
  [monitor notify:MVSettingManagerColorActiveColor];
}

+ (MVSettingManagerColor)colorSetting
{
  return [[MVSettingManagerColor alloc] init];
}

@end

@implementation MVSettingManagerColorButton : CPView
{
  CPColor color;
  id target;
  BOOL active;
}

- (id)initWithColor:(CPColor)in_color target:(id)in_target
{
  if(self = [super initWithFrame:CPRectMake(0, 0, 30, 30)]){
    color = in_color;
    target = in_target;
    active = NO;
  }
  return self;
}

- (CPColor)color
{
  return color;
}

- (void)mouseUp:(CPEvent)evt
{
  [target selectColor:color];
}

- (void)setActive:(BOOL)in_active
{
  active = in_active;
  [self setNeedsDisplay:YES];
}

- (void)drawRect:(CPRect)rect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  CGContextSaveGState(context);
    CGContextSetStrokeColor(
      context, 
      active ? [CPColor redColor] : [CPColor grayColor]);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeRect(context, CPRectInset(rect, 2, 2));
    [color setFill];
    CGContextFillRect(context, CPRectInset(rect, 5, 5));
  CGContextRestoreGState(context);
}

@end
