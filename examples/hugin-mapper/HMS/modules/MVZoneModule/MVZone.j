function three_five_distance(a, b){
  return Math.floor(Math.max(Math.abs(a.x-b.x), Math.abs(a.y-b.y)) +
                    Math.min(Math.abs(a.x-b.x), Math.abs(a.y-b.y))/2 );
}

function ceil_mod(a, b){
  return a -(Math.ceil(a/b)*b);
}

@implementation MVZone : CPView
{
  id definition;
  CPString key;
  MVZoneModule zm;
  BOOL highlighted;
}

- (id)initWithKey:(CPString)in_key 
      definition:(id)in_definition 
      zoneModule:(MVZoneModule)in_zm
{
  if(self = [super initWithFrame:CPRectMakeZero()]){
    key = in_key;
    zm = in_zm;
    highlighted = NO;
    [self updateDefinition:in_definition];
  }
  return self;
}

+ (CPString)defaultColor
{
  return [[CPColor blueColor] hexString];
}

- (void)setColor:(CPColor)color
{
  definition.color = [color hexString];
  [self setNeedsDisplay:YES];
}

- (void)setHighlighted:(BOOL)in_highlighted
{
  if(highlighted != in_highlighted) { [self setNeedsDisplay:YES]; }
  highlighted = in_highlighted;
}

- (void)reposition
{
  [self setFrameOrigin:[[zm mapview] pixelForPosition:[self squareOrigin]]];
}

- (void)resize
{
  [self reposition];
  [self setFrameSize:[[zm mapview] pixelSizeFromSize:[self squareSize]]];
  [self setNeedsDisplay:YES];
}

- (id)drawRect:(CPRect)area
{
  var squareSize = [zm squareSize];
  var context = [[CPGraphicsContext currentContext] graphicsPort];

  CGContextSaveGState(context);

  [[[CPColor colorWithHexString:definition.color] 
    colorWithAlphaComponent:(highlighted ? 0.8 : 0.5)]
      setFill];

  var drawSquare = function(point){
    CGContextFillRect(context,
                      CPRectInset(
                        CPRectMake(point.x * squareSize.width, 
                                   point.y * squareSize.height,
                                   squareSize.width, squareSize.height), 3, 3));
  }
  
  [self fillZoneSquares:drawSquare];
  
  CGContextRestoreGState(context);
}
- (void)updateDefinition:(id)in_definition
{
  definition = in_definition;
  [self validateDefinition];
  [self resize];
}

- (void)zoneDeleted
{
  [self removeFromSuperview];
}

- (id)definition
{
  return definition;
}

@end

@implementation MVRectangleZone : MVZone
{

}

- (void)validateDefinition
{
  if(!definition.color){ definition.color = [MVZone defaultColor]; }
  if(!definition.origin) { definition.origin = CPPointMake(0,0); }
  if(!definition.size) { definition.size = CPSizeMake(1,1); }
}

- (void)dragToPoint:(CPPoint)pt
{
  definition.size.width = Math.floor(pt.x) - definition.origin.x;
  if(definition.size.width >= 0){ definition.size.width += 1; }
  definition.size.height = Math.floor(pt.y) - definition.origin.y;
  if(definition.size.height >= 0){ definition.size.height += 1; }

  [self resize];
}

- (void)squareSize
{
  return CPSizeMake(Math.abs(definition.size.width), 
                    Math.abs(definition.size.height));
}

- (void)squareOrigin
{
  return CPPointMake(
    Math.min(definition.origin.x, definition.origin.x + definition.size.width),
    Math.min(definition.origin.y, definition.origin.y + definition.size.height)
  );
}

- (void)fillZoneSquares:(id)drawSquare
{
  var pt = CPPointMake(0,0);
  for(pt.x = 0; pt.x < Math.abs(definition.size.width); pt.x++){
    for(pt.y = 0; pt.y < Math.abs(definition.size.height); pt.y++){
      drawSquare(pt);
    }
  }
}

@end



@implementation MVD20CircleZone : MVZone
{
  
}

- (void)validateDefinition
{
  if(!definition.color){ definition.color = [MVZone defaultColor]; }
  if(!definition.origin) { definition.origin = CPPointMake(0,0); }
  if(!definition.radius) { definition.radius = 1; }
}

- (void)dragToPoint:(CPPoint)pt
{
  definition.radius = Math.floor(Math.sqrt(
    Math.pow(Math.abs(definition.origin.x - Math.floor(pt.x)), 2) +
    Math.pow(Math.abs(definition.origin.y - Math.floor(pt.y)), 2)
  ));

  [self resize];
}

- (void)squareSize
{
  return CPSizeMake(2*definition.radius, 2*definition.radius);
}

- (void)squareOrigin
{
  return CPPointMake(definition.origin.x - definition.radius,
                     definition.origin.y - definition.radius);
}

- (void)fillZoneSquares:(id)drawSquare
{
  var pt = CPPointMake(0,0);
  var origin = CPPointMake(definition.radius-0.5,definition.radius-0.5);
  for(pt.x = 0; pt.x < definition.radius * 2; pt.x++){
    for(pt.y = 0; pt.y < definition.radius * 2; pt.y++){
      if(three_five_distance(origin, pt) < definition.radius){
        drawSquare(pt);
      }
    }
  }
}

@end

@implementation MVLineZone : MVZone
{

}

- (void)validateDefinition
{
  if(!definition.color){ definition.color = [MVZone defaultColor]; }
  if(!definition.origin) { definition.origin = CPPointMake(0,0); }
  if(!definition.offset) { definition.offset = CPPointMake(1,1); }
}

- (void)squareSize
{
  return CPSizeMake(Math.abs(definition.offset.x) + 1, 
                    Math.abs(definition.offset.y) + 1);
}

- (void)dragToPoint:(CPPoint)pt
{
  definition.offset = CPPointMake(
    Math.floor(pt.x) - definition.origin.x,
    Math.floor(pt.y) - definition.origin.y
  );
  [self resize];
}

- (void)squareOrigin
{
  return CPPointMake(
    Math.min(definition.origin.x, definition.origin.x+definition.offset.x),
    Math.min(definition.origin.y, definition.origin.y+definition.offset.y)
  );
}

- (void)fillZoneSquares:(id)drawSquare
{
  var steps = Math.max(Math.abs(definition.offset.x), 
                       Math.abs(definition.offset.y));
  var delta = CPPointMake(Math.max(-definition.offset.x, 0), 
                          Math.max(-definition.offset.y, 0));
  for(i = 0; i <= steps; i++){
    var pt = 
      CPPointMake(delta.x + Math.round((definition.offset.x) * (i / steps)),
                  delta.y + Math.round((definition.offset.y) * (i / steps)));
    drawSquare(pt);
  }
}

@end

@implementation MVD20ConeZone : MVZone
{

}

- (void)validateDefinition
{
  if(!definition.color){ definition.color = [MVZone defaultColor]; }
  if(!definition.origin) { definition.origin = CPPointMake(0,0); }
  if(!definition.radius) { definition.radius = 1; }
  if(definition.direction === nil) { definition.direction = 1; }
}

- (void)squareSize
{
  if(definition.direction % 2 == 0){
    // angled
    return CPSizeMake(definition.radius, definition.radius);
  } else {
    // cardinal 4
    if(definition.radius <= 3){
      return CPSizeMake(definition.radius, definition.radius);
    } else {
      var ret = CPSizeMake(Math.ceil(definition.radius * Math.sqrt(2)),
                           definition.radius);
      if((definition.direction - 1) % 4 == 0){
        // > 3 squares, and directed horizontally
        // swap the directions
        var tmp = ret.width;
        ret.width = ret.height;
        ret.height = tmp;
      }
      return ret;
    }
  }
}

- (void)squareOrigin
{
  var ret = CPPointCreateCopy(definition.origin);
  var cardinalOffset = (definition.offset ? 0 : 1);
  if(definition.radius > 3){ 
    cardinalOffset += Math.floor(definition.radius / Math.sqrt(2));
  } else {
    cardinalOffset += Math.floor(definition.radius / 3);
  }
  switch(definition.direction){
    case 0: //UR
      ret.y -= definition.radius; break;
    case 1: //R
      ret.y -= cardinalOffset; break;
    case 2: //LR
      break;
    case 3: //D
      ret.x -= cardinalOffset; break;
    case 4: //LL
      ret.x -= definition.radius; break;
    case 5: //L
      ret.y -= cardinalOffset; ret.x -= definition.radius; break;
    case 6: //UL
      ret.x -= definition.radius; ret.y -= definition.radius; break;
    case 7: //U
      ret.x -= cardinalOffset; ret.y -= definition.radius; break;
  }
  return ret;
}

- (void)dragToPoint:(CPPoint)pt
{
  var dx = pt.x - definition.origin.x;
  var dy = pt.y - definition.origin.y;
  var adx = Math.abs(dx), ady = Math.abs(dy);
  
  definition.radius = Math.max(1, Math.ceil(Math.sqrt(dx*dx+dy*dy)));
  if((Math.max(adx, ady) * 2.0 / 3.0) > Math.min(adx, ady)){ 
    if(adx > ady){
      if(dx > 0){ definition.direction = 1; }
           else { definition.direction = 5; }
      definition.offset = (dy > 0);
    } else {
      if(dy > 0){ definition.direction = 3; }
           else { definition.direction = 7; }
      definition.offset = (dx > 0); 
    }
    definition.radius += 1;
  } else {  
    if(dx > 0){
      if(dy < 0){ definition.direction = 0; }
           else { definition.direction = 2; }
    } else {
      if(dy > 0){ definition.direction = 4; }
           else { definition.direction = 6; }
    }
  }
  
  [self resize];
}

- (void)fillZoneSquares:(id)drawSquare
{
  if((definition.direction % 2) == 0){
    //angled
    var pt = CPPointMake(0,0);
    var origin;
    switch(definition.direction){
      case 0://UR
        origin = CPPointMake(-1, definition.radius); break;
      case 2://LR
        origin = CPPointMake(-1, -1); break;
      case 4://LL
        origin = CPPointMake(definition.radius, -1); break;
      case 6://UL
        origin = CPPointMake(definition.radius, 
                             definition.radius); break;
    }
    for(pt.x = 0; pt.x < definition.radius; pt.x++){
      for(pt.y = 0; pt.y < definition.radius; pt.y++){
        if(three_five_distance(origin,pt) <= definition.radius){
          drawSquare(pt);
        }
      }
    }
  } else {
    //cardinal direction.  Locational offsetting is taken care of by 
    //squareOrigin, but we still need to reflect the squares for radius 2,
    //since that's not symmetric
    if(definition.radius == 1){
      drawSquare(CPPointMake(0,0))
    } else if(definition.radius == 2){
      if(  (( definition.offset) && (definition.direction == 1)) //R
         ||((!definition.offset) && (definition.direction == 7)))//U
      {
        // ' X X
        //     X .
        drawSquare(CPPointMake(0,0));
        drawSquare(CPPointMake(1,0));
        drawSquare(CPPointMake(1,1));
      } else 
      if(  ((!definition.offset) && (definition.direction == 1)) //R
         ||((!definition.offset) && (definition.direction == 3)))//D
      {
        //     X '
        // . X X
        drawSquare(CPPointMake(0,1));
        drawSquare(CPPointMake(1,0));
        drawSquare(CPPointMake(1,1));
      } else 
      if(  (( definition.offset) && (definition.direction == 5)) //L
         ||(( definition.offset) && (definition.direction == 7)))//U
      {
        //   X X '
        // . X 
        drawSquare(CPPointMake(0,0));
        drawSquare(CPPointMake(0,1));
        drawSquare(CPPointMake(1,0));
      } else 
      if(  (( definition.offset) && (definition.direction == 3)) //D
         ||((!definition.offset) && (definition.direction == 5)))//L
      {
        // ' X
        //   X X .
        drawSquare(CPPointMake(0,0));
        drawSquare(CPPointMake(0,1));
        drawSquare(CPPointMake(1,1));
      } 
    } else if(definition.radius == 3){
      var dir = definition.direction;
      drawSquare(CPPointMake(1,1));
      drawSquare(CPPointMake(0,1));
      drawSquare(CPPointMake(1,0));
      drawSquare(CPPointMake(2,1));
      drawSquare(CPPointMake(1,2));
      if((dir == 1) || (dir == 3)){ drawSquare(CPPointMake(2,2)); }
      if((dir == 1) || (dir == 7)){ drawSquare(CPPointMake(2,0)); }
      if((dir == 5) || (dir == 3)){ drawSquare(CPPointMake(0,2)); }
      if((dir == 5) || (dir == 7)){ drawSquare(CPPointMake(0,0)); }
    } else { //radius > 3
      var pt = CPPointMake(0,0);
      var offsetToOrigin = Math.ceil(definition.radius / Math.sqrt(2)) - 0.5;
      var origin = CPPointMake(-1, offsetToOrigin);
      var rotatePoint;
      switch(definition.direction){
        case 1: rotatePoint = function(pt) { return pt; }; break;
        case 3: rotatePoint = function(pt) { return CPPointMake(pt.y,pt.x);
          }; break;
        case 5: rotatePoint = function(pt) { 
            return CPPointMake(definition.radius - pt.x - 1, pt.y); 
          }; break;
        case 7: rotatePoint = function(pt) { 
            return CPPointMake(pt.y, definition.radius - pt.x - 1); 
          }; break;
      }
      for(pt.x = 0; pt.x < definition.radius; pt.x++){
        for(pt.y = 0; pt.y < definition.radius * 2; pt.y++){
          if((three_five_distance(pt, origin) <= definition.radius) &&
             (Math.abs(pt.y - offsetToOrigin) - 0.5 <= pt.x)){
              drawSquare(rotatePoint(pt));
          }
        }
      }
    }
  }
}

@end