@implementation MVWhiteboardSprayShape : CPObject
{
  MapView mv;
  CPRect bounds;
  id shape;
  int scaled_size;
}

- (id)initWithMapView:(MapView)in_mv attributes:(id)in_shape
{
  if(self = [super init]){
    mv = in_mv;
    bounds = CPRectMakeZero();
    if(in_shape.points){
      for(var pt in in_shape.points){
        MVWM_ExtendBounds(pt, bounds);
      }
    }
    shape = { 
      type : [self shapeType],
      points : in_shape.points ? in_shape.points : [],
      color : in_shape.color,
      size : (in_shape.size ? in_shape.size : 25),
      alpha : (in_shape.alpha ? in_shape.alpha : 0.2)
    };
    scaled_size = shape.size / [mv gridSize];
  }
  return self;
}

- (CPString)shapeType
{
  return "spray";
}

- (void)moveDrawToPoint:(CPPoint)pt
{
  MVWM_ExtendBounds(pt, bounds);
  shape.points[shape.points.length] = pt;
}

- (CPRect)bounds
{
//  return bounds;
  return CPRectMake(
    bounds.origin.x,// - scaled_size,
    bounds.origin.y,// - scaled_size,
    bounds.size.width + scaled_size * 2,
    bounds.size.height + scaled_size * 2
  );
}

+ (void)drawShape:shape mapView:(MapView)mv
{
  var context = [[CPGraphicsContext currentContext] graphicsPort]
  MVWM_SetColorInfo(shape);
  var scale = [mv gridSize] / 50.0;
  var size = shape.size * scale;
  var halfsize = size / 2.0;
  for(var pt in shape.points){
    if(pt == "isa"){ continue; }
    pt = [mv pixelForPosition:shape.points[pt]];
    CGContextFillEllipseInRect(
      context, 
      CPRectMake(pt.x - halfsize, pt.y - halfsize, 
                 size, size)
    );
  }
}

- (void)drawShape
{
  [MVWhiteboardSprayShape drawShape:shape mapView:mv];
}

- (id)serialize
{
  return shape;
}

@end

@implementation MVWhiteboardEraserShape : MVWhiteboardSprayShape
{

}

- (id)initWithMapView:(MapView)in_mv attributes:(id)in_shape
{
  if(self = [super initWithMapView:in_mv attributes:in_shape]){
    if(in_shape.thickness){
      shape.size *= ((in_shape.thickness - 1) * 0.5) + 1
    }
  }
  return self;
}

- (CPString)shapeType
{
  return "eraser";
}

+ (void)drawShape:shape mapView:(MapView)mv
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  var scale = [mv gridSize] / 50.0;
  var size = shape.size * scale;
  var halfsize = size / 2.0;
  for(var pt in shape.points){
    if(pt == "isa"){ continue; }
    pt = [mv pixelForPosition:shape.points[pt]];
    CGContextClearRect(
      context, 
      CPRectMake(pt.x - halfsize, pt.y - halfsize, 
                 size, size)
    );
  }
}

- (void)drawShape
{
  [MVWhiteboardEraserShape drawShape:shape mapView:mv]
}

@end
