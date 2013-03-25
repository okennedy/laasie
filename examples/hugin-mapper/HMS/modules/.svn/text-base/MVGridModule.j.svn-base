@implementation MVGridModule : CPView
{
  int squareWidth;
  CPPoint line_count;
  CPPoint last_mouse_down;
  MapView mv;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  if(self = [super initWithFrame:CPRectMakeZero()]){
    gridWidth = nil;
    line_count = CPPointMake(0, 0);
    last_mouse_down = nil;
    mv = in_mv
  }
  return self;
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{
  var targetRect = [mv viewableRegion];
  var in_squareWidth = [mv gridSize];
  
  [self setFrameOrigin:
    CPPointMake(
      (Math.floor(targetRect.origin.x) - targetRect.origin.x) 
        * in_squareWidth - 5,
      (Math.floor(targetRect.origin.y) - targetRect.origin.y) 
        * in_squareWidth - 5
    )];
  if(Math.ceil(targetRect.size.width)+1 > line_count.x || 
     Math.ceil(targetRect.size.height)+1 > line_count.y ||
     squareWidth != in_squareWidth){
    squareWidth = in_squareWidth;
    line_count = CPPointMake(
      Math.ceil(targetRect.size.width)+1,
      Math.ceil(targetRect.size.height)+1
    );
    [self setFrameSize:CPSizeMake(line_count.x * squareWidth + 10, 
                                  line_count.y * squareWidth + 10)];
    CPLog("Grid asking for redraw now");
    [self setNeedsDisplay:YES];
  }
}

- (void)drawRect:(CPRect)aRect
{
  CPLog("Grid redrawing");
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  var i;
  CGContextSaveGState(context);
    CGContextSetStrokeColor(context, "grey");
    CGContextSetLineWidth(1);

    for(i = 0; i <= line_count.x; i++){
      CGContextStrokeRect(
        context,
        CPRectMake((i * squareWidth) + 5, 0, 0, [self frameSize].height)
      );
//      CGContextStrokeLineSegments(
//        context, [
//          CPPointMake(i * squareWidth + 5, 0),
//          CPPointMake(i * squareWidth + 5, [self frameSize].height)
//        ]);
    }
    for(i = 0; i <= line_count.y; i++){
      CGContextStrokeRect(
        context,
        CPRectMake(0, (i * squareWidth) + 5, [self frameSize].width, 0)
      );
      CGContextStrokeLineSegments(
        context, [
          CPPointMake(0, i * squareWidth + 5),
          CPPointMake([self frameSize].width, i * squareWidth + 5)
        ]);
    }
  CGContextRestoreGState(context);
  CPLog("Grid done");
}

- (CPString)description
{
  return "MVGridModule";
}

- (id)mvModuleInfo
{
  return { 
    view : self,
    tools : {
      General : { 
        Hand : { 
//          image : [[CPImage alloc] initWithContentsOfFile:"Resources/hand.png"],
          image : [[CPImage alloc] initWithContentsOfFile:"Resources/transform-move.png"],
          mouseDownSel : @selector(handMouseDown:),
          mouseDragSel : @selector(handMouseDrag:),
          mouseUpSel   : @selector(handMouseUp:)
        }
      }
    },
    menu : {
      General : {
        "Revert to Origin" : {
          target : self,
          action : @selector(revertToOrigin:)
        }
      },
      Scale : {
        "50%" : {
          target : self,
          action : @selector(setScaleTiny:),
        },
        "75%" : {
          target : self,
          action : @selector(setScaleSmall:),
        },
        "100%" : {
          target : self,
          action : @selector(setScaleNormal:),
        },
        "200%" : {
          target : self,
          action : @selector(setScaleLarge:),
        },
      }
    }
  };
}

- (void)revertToOrigin:(id)sender
{
  CPLog("Reverting");
  [mv setViewableOriginToPosition:CPPointMake(0,0)];
}

- (void)handMouseDown:(CPPoint)point
{
  last_mouse_down = point;
}

- (void)handMouseDrag:(CPPoint)point
{
  if(last_mouse_down){
    var offset = CPPointMake(
      last_mouse_down.x - point.x,
      last_mouse_down.y - point.y
    )
//    CPLog("Offset by : " + CPStringFromPoint(offset) + "; " + CPStringFromPoint(point) + "; " + CPStringFromPoint(last_mouse_down));
    [mv offsetViewableByPosition:offset];
    // We don't update last_mouse_down, because offsetViewableByPosition:
    // does that for us.  Specifically, we get the position on the map, not
    // the pixel on the screen.  Consequently, if we drag some distance away,
    // the new "origin" point should be still under the mouse.
  } else {
    last_mouse_down = point;
  }
}
- (void)handMouseUp:(CPPoint)point
{
  last_mouse_down = nil;
}

- (IBAction)setScaleTiny:(id)sender
{
  [mv setGridSize:25];
}

- (IBAction)setScaleSmall:(id)sender
{
  [mv setGridSize:37];
}

- (IBAction)setScaleNormal:(id)sender
{
  [mv setGridSize:50];
}

- (IBAction)setScaleLarge:(id)sender
{
  [mv setGridSize:100];
}

@end