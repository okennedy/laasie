
@implementation MVZoneTypeButton : CPView
{
  CPString name;
  id target;
  BOOL active;
}

- (id)initWithName:(CPString)in_name image:(CPImage)in_img target:(id)in_target
{
  if(self = [super initWithFrame:CPRectMake(0,0,35,35)]){
    name = in_name;
    target = in_target;
    active = NO;
    
    var image_view = [[CPImageView alloc] initWithFrame:CPRectMake(5,5,25,25)];
    [image_view setImage:in_img];
    [self addSubview:image_view];
  }
  return self;
}

- (CPString)type
{
  return name;
}

- (void)mouseUp:(CPEvent)evt
{
  [target selectZoneType:name];
}

- (void)setActive:(BOOL)in_active
{
  active = in_active
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
  CGContextRestoreGState(context);
}

@end

@implementation MVZoneTypeSetting : MVSettingManagerSetting
{
  CPArray zone_types;
}

- (void)addZoneType:(CPString)name img:(CPString)img at:(CPPoint)pt
{
  var t = [[MVZoneTypeButton alloc] 
              initWithName:name
              image:[[CPImage alloc] initWithContentsOfFile:"Resources/"+img]
              target:self];
  [zone_types addObject:t];
  [t setFrameOrigin:pt];
  [self addSubview:t];
}

- (id)init
{
  if(self = [super initWithFrame:CPRectMake(0,0, 200, 40)]){
    zone_types = [[CPArray alloc] init];
    [self watchGlobalSetting:"ZONE_TYPE"];
    var y = 0;
    var min_x = [self addLabel:"Type" at:CPPointMake(5,y+5)];
    var x = min_x;
    [self addZoneType:"d20circle" img:"burst.png"
          at:CPPointMake(x,y)]; x += 35;
    [self addZoneType:"d20cone"  img:"cone.png"
          at:CPPointMake(x,y)]; x += 35;
    [self addZoneType:"rectangle"  img:"rectangle.png"
          at:CPPointMake(x,y)]; x += 35;
    [self addZoneType:"line"  img:"line.png"
          at:CPPointMake(x,y)]; x += 35;    
    [self settingUpdated:[MVZoneModule activeZoneType]];
  }
  return self;
}

- (void)selectZoneType:(CPString)type
{
  [self updateGlobalSetting:type];
  [MVZoneModule setActiveZoneType:type];
}

- (void)settingUpdated:(CPString)type
{
  var zone_iter = [zone_types objectEnumerator];
  var zone;
  while(zone = [zone_iter nextObject]){
    [zone setActive:([[zone type] isEqualToString:type])];
  }
}

+ (void)monitorWithTarget:target
        selector:selector
{
  var monitor =
    [MVSettingManager monitorSetting:"ZONE_TYPE"
                      target:target
                      selector:selector];
  [monitor notify:[MVZoneModule activeZoneType]];
}
@end
