@implementation MVWhiteboardPencilShape : CPObject
{
  MapView mv;
  CPRect bounds;
  id shape;
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
      type : "line",
      points : (in_shape.points ? in_shape.points : []),
      color : in_shape.color,
      thickness : in_shape.thickness
    };
  }
  return self;
}

- (CPString)shapeType
{
  return "pencil"
}

- (void)moveDrawToPoint:(CPPoint)pt
{
  MVWM_ExtendBounds(pt, bounds);
  shape.points[shape.points.length] = pt;
}

- (CPRect)bounds
{
  return bounds;
}

+ (void)drawShape:shape mapView:(MapView)mv
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  MVWM_SetLineInfo(shape, mv);
  var segments = [];
  var last = null;
  for(var pt in shape.points){
    if(pt == "isa"){ continue; }
    pt = [mv pixelForPosition:shape.points[pt]];
    if(last){
      segments[segments.length] = last;
      segments[segments.length] = pt;
    }
    last = pt;
  }
  CGContextStrokeLineSegments(context, segments, segments.length);
}

- (void)drawShape
{
  [MVWhiteboardPencilShape drawShape:shape mapView:mv];
}

- (id)serialize
{
  return shape;
}

@end

@implementation MVWhiteboardLineShape : MVWhiteboardPencilShape
{

}

- (CPString)shapeType
{
  return "line"
}

- (void)moveDrawToPoint:(CPPoint)pt
{
  bounds = CPRectMake(pt.x, pt.y, 0, 0);
  if(shape.points.length == 0){
    shape.points[0] = pt;
  } else {
    shape.points[1] = pt;
    MVWM_ExtendBounds(pt, bounds);
  }
}

+ (void)drawShape:shape mapView:(MapView)mv
{
  [super drawShape:shape mapView:mv];
}
@end
