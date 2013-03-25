@implementation MVWhiteboardRectangleShape : CPObject
{
  MapView mv;
  id shape;
  CPPoint origin;
}

- (id)initWithMapView:(MapView)in_mv attributes:(id)in_shape
{
  if(self = [super init]){
    mv = in_mv;
    origin = nil;
    shape = { 
      type : [self shapeType],
      "origin" : (in_shape.origin ? in_shape.origin : nil),
      size : (in_shape.size ? in_shape.size : CPSizeMake(0,0)),
      color : in_shape.color,
      alpha : (in_shape.alpha ? in_shape.alpha : 1)
    };
  }
  return self;
}

- (CPString)shapeType
{
  return "rectangle"
}

- (void)moveDrawToPoint:(CPPoint)pt
{
  if(origin == nil){
    origin = CPPointCreateCopy(pt);
    shape.origin = pt;
  } else {
    shape.origin.x = Math.min(origin.x, pt.x);
    shape.origin.y = Math.min(origin.y, pt.y);
    shape.size.width = Math.abs(origin.x - pt.x);
    shape.size.height = Math.abs(origin.y - pt.y);
  }
}

- (CPRect)bounds
{
  return shape;
}

+ (void)drawShape:(id)shape mapView:(MapView)mv
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  MVWM_SetColorInfo(shape);
  CGContextFillRect(context, [mv pixelRectFromRect:shape]);
}

- (void)drawShape
{
  [MVWhiteboardRectangleShape drawShape:shape mapView:mv];
}

- (id)serialize
{
  return shape;
}

@end


@implementation MVWhiteboardOvalShape : MVWhiteboardRectangleShape
{

}

- (CPString)shapeType
{
  return "oval"
}

+ (void)drawShape:shape mapView:(MapView)mv
{
  var context = [[CPGraphicsContext currentContext] graphicsPort]
  MVWM_SetColorInfo(shape);
  CGContextFillEllipseInRect(context, [mv pixelRectFromRect:shape]);
}
- (void)drawShape
{
  [MVWhiteboardOvalShape drawShape:shape mapView:mv];
}

@end