var MVSettingManagerThicknessActiveThickness = 1;

@implementation MVSettingManagerThickness : MVSettingManagerSetting
{
  CPArray thickness_buttons;
}

- (void)addThicknessButton:(int)thickness at:(CPPoint)pt
{
  var t;
  t = [[MVSettingManagerThicknessButton alloc] 
          initWithThickness:thickness target:self];
  [thickness_buttons addObject:t];
  [t setFrameOrigin:pt];
  [self addSubview:t];
}

- (id)init
{
  if(self = [super initWithFrame:CPRectMake(0, 0, 200, 25)]){
    CPLog("MVSettingManagerThickness init");
    [self watchGlobalSetting:"LINE_THICKNESS"];
    thickness_buttons = [[CPArray alloc] init];
    var x = [self addLabel:"Thickness" at:CPPointMake(5, 2)];
    [self addThicknessButton:1  at:CPPointMake(x, 0)]; x += 20;
    [self addThicknessButton:2  at:CPPointMake(x, 0)]; x += 20;
    [self addThicknessButton:3  at:CPPointMake(x, 0)]; x += 20;
    [self addThicknessButton:4  at:CPPointMake(x, 0)]; x += 20;
    [self addThicknessButton:5  at:CPPointMake(x, 0)]; x += 20;
    [self addThicknessButton:10 at:CPPointMake(x, 0)]; x += 20;
    [self settingUpdated:MVSettingManagerThicknessActiveThickness];
  }
  return self;
}

- (void)selectThickness:(int)thickness
{
  [self updateGlobalSetting:thickness];
  MVSettingManagerThicknessActiveThickness = thickness;
}

- (void)settingUpdated:(int)thickness
{
  var tb_iter = [thickness_buttons objectEnumerator];
  var tb;
  while(tb = [tb_iter nextObject]){
    [tb setActive:([tb thickness] == thickness)];
  }
}

+ (void)monitorWithTarget:target
        selector:selector
{
  var monitor =
    [MVSettingManager monitorSetting:"LINE_THICKNESS"
                      target:target
                      selector:selector];
  [monitor notify:MVSettingManagerThicknessActiveThickness];
}

+ (MVSettingManagerThickness)thicknessSetting
{
  return [[MVSettingManagerThickness alloc] init];
}

@end

@implementation MVSettingManagerThicknessButton : CPView
{
  int thickness;
  id target;
  BOOL active;
}

- (id)initWithThickness:(int)in_thickness target:(id)in_target
{
  if(self = [super initWithFrame:CPMakeRect(0, 0, 20, 20)]){
    thickness = in_thickness;
    target = in_target;
    active = NO;
  }
  return self;
}

- (int)thickness
{
  return thickness;
}

- (void)mouseUp:(CPEvent)evt
{
  [target selectThickness:thickness];
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
    var color = active ? [CPColor redColor] : [CPColor grayColor];
    [color setStroke];
    [color setFill];
    CGContextSetLineWidth(context, 1);
    CGContextStrokeRect(context, CPRectInset(rect, 2, 2));
    CGContextFillRect(
      context,
      CPRectMake((rect.size.width / 2) - (thickness * 0.5), 5, 
                 (thickness * 1.0), rect.size.height - 10)
    );
  CGContextRestoreGState(context);
}

@end
