// JSONTable @ core/shapes
// shape.type = line || eraser || square || oval || spray
// line = { points, color, thickness }
// eraser = { points, size : int }
// square = { origin : CPPoint, size : CPSize, color, alpha } 
// oval = { origin : CPPoint, size : CPSize, color, alpha } 
// spray = { points, color, size, alpha : int }

@import "../../mapview/settingmanager/MVSettingManager.j"
@import "MVWhiteboardPencilShape.j" //includes line
@import "MVWhiteboardSprayShape.j" //includes eraser
@import "MVWhiteboardRectangleShape.j" //includes circle

function MVWM_PixelForPoint(pt, mv, offset){
  var ret = [mv pixelForPosition:pt];
  ret.x -= offset.x;
  ret.y -= offset.y;
  return ret;
}

function MVWM_ExtendBounds(target, bounds){
  if(target.x < bounds.origin.x){
    bounds.size.width += bounds.origin.x - target.x;
    bounds.origin.x = target.x;
  }
  if(target.y < bounds.origin.y){
    bounds.size.height += bounds.origin.y - target.y;
    bounds.origin.y = target.y;
  }
  if(target.x > bounds.origin.x + bounds.size.width){
    bounds.size.width = target.x - bounds.origin.x;
  }
  if(target.y > bounds.origin.y + bounds.size.height){
    bounds.size.height = target.y - bounds.origin.y;
  }
}

function MVWM_MergeBounds(source, dest){
  MVWM_ExtendBounds(source.origin, dest);
  MVWM_ExtendBounds(
    CPPointMake(
      source.origin.x+source.size.width,
      source.origin.y+source.size.height
    ), dest
  );
}

function MVWM_SetLineInfo(shape, mv){
  CGContextSetLineWidth(
    [[CPGraphicsContext currentContext] graphicsPort],
    shape.thickness * 1.0 * [mv gridSize] / 50.0
  );
  [[CPColor colorWithHexString:shape.color] setStroke];
}

function MVWM_SetColorInfo(shape){
  [[CPColor colorWithHexString:shape.color] setFill];
  //alpha doesn't seem to work at the moment.  Must be in alpha. ha. ha.
  CGContextSetAlpha(
    [[CPGraphicsContext currentContext] graphicsPort],
    shape.alpha
  );
}

@implementation MVWhiteboardModule : CPView
{
  id shapes;
  id shape_types;
  MapView mv;
  ICON icon_hub;
  id pending_shape;
  CPArray local_only_shapes;
  CPArray setting_views;
  id shape_attrs;
  MVToolManagerSettingView line_setting_view;
  MVToolManagerSettingView shape_setting_view;
  MVToolManagerSettingView eraser_setting_view;
}

- (MVToolManagerSettingView)settingViewWithMask:(int)mask
{
  var sv = [[MVToolManagerSettingView alloc] 
                initWithMask:mask
                target:self];
  [setting_views addObject:sv];
  return sv;
}

- (id)initWithMapView:(MapView)in_mv settings:(id)settings
{
  CPLog("Setting up whiteboard");
  if(self = [super init]){
    mv = in_mv;
    shape_attrs = {
      color : [[CPColor blackColor] hexString],
      thickness : 1,
      alpha : 1
    }
    shape_types = {
      "rectangle" : MVWhiteboardRectangleShape,
      "oval"      : MVWhiteboardOvalShape,
      "spray"     : MVWhiteboardSprayShape,
      "pencil"    : MVWhiteboardPencilShape,
      "line"      : MVWhiteboardLineShape,
      "eraser"    : MVWhiteboardEraserShape
    }
    pending_shape = nil;
    local_only_shapes = [[CPArray alloc] init];
    setting_views = [[CPArray alloc] init];
    
    line_setting_view = [MVSettingManager settingFrame];
    [line_setting_view 
      addSetting:[MVSettingManagerThickness thicknessSetting]];
    [line_setting_view 
      addSetting:[MVSettingManagerColor colorSetting]];

    shape_setting_view = [MVSettingManager settingFrame];
    [shape_setting_view
      addSetting:[MVSettingManagerColor colorSetting]];
    
    eraser_setting_view = [MVSettingManager settingFrame];
    [eraser_setting_view 
      addSetting:[MVSettingManagerThickness thicknessSetting]];
    
    [MVSettingManagerColor monitorWithTarget:self 
                           selector:@selector(selectColor:)];
    [MVSettingManagerThickness monitorWithTarget:self 
                               selector:@selector(selectThickness:)];
  }
  CPLog("Whiteboard set up");
  return self;
}

- (id)mvModuleInfo
{ 
  return {
    view : self,
    menu : {
      Cleanup : {
        "Clear Whiteboard" : {
          target : self,
          action : @selector(promptClearWhiteboard:)
        }
      }
    },
    tools : {
      General : {
        Eraser : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/draw-eraser-2.png"],
          mouseDownSel : @selector(eraserMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : eraser_setting_view
        },
        Pencil : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/draw-path.png"],
          mouseDownSel : @selector(pencilMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : line_setting_view
        },
        Brush : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/draw-brush.png"],
          mouseDownSel : @selector(sprayMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : shape_setting_view
        },
        Line : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/line2.png"],
          mouseDownSel : @selector(lineMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : line_setting_view
        },
        "Rectangle" : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/draw-rectangle-2.png"],
          mouseDownSel : @selector(rectangleMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : shape_setting_view
        },
        "Oval" : {
          image : [[CPImage alloc] 
                      initWithContentsOfFile:"Resources/draw-circle-2.png"],
          mouseDownSel : @selector(ovalMouseDown:),
          mouseDragSel : @selector(dragShape:),
          mouseUpSel   : @selector(commitShape:),
          toolView     : shape_setting_view
        }
      }
    }
  };
}

- (void)mvSetICONHub:(ICONHub)in_icon_hub
{
  icon_hub = in_icon_hub;
  [icon_hub registerForUpdatesToPath:[icon_hub path]+"/shapes"
            target:self
            selector:@selector(shapesUpdated:)]
}

- (void)shapesUpdated:(id)in_shapes
{
  shapes = in_shapes;

  // filter out all local-only shapes that have been echoed from the repository
  var i = 0;
  while(i < [local_only_shapes count]){
    var shape = [local_only_shapes objectAtIndex:i];
    if(shape.timestamp <= [icon_hub timestamp]){
      CPLog("Deleting local shape %@ (timestamp %@)", shape.shape, shape.timestamp)
      [local_only_shapes removeObjectAtIndex:i];
    } else {
      i++;
    }
  }

  [self setNeedsDisplay:YES];
}

- (void)eraserMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardEraserShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)pencilMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardPencilShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)lineMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardLineShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)sprayMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardSprayShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)rectangleMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardRectangleShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)ovalMouseDown:(CPPoint)pt
{
  pending_shape = 
    [[MVWhiteboardOvalShape alloc] 
      initWithMapView:mv 
      attributes:shape_attrs];
  [pending_shape moveDrawToPoint:pt];
}

- (void)dragShape:(CPPoint)pt
{
  [pending_shape moveDrawToPoint:pt];
  [self setNeedsDisplay:YES];
}

- (void)commitShape:(CPPoint)pt
{
  var commitTS = 
    [icon_hub immediateAppendToPath:[icon_hub path]+"/shapes"
              data:[pending_shape serialize]];
  [local_only_shapes addObject:{ "timestamp" : commitTS, 
                                 "shape" : pending_shape }];
  pending_shape = nil;
  
//  [shapes addObject:pending_shape];
//  pending_shape = nil;
}

- (void)mapViewUpdatedPosition:(MapView)in_mv
{
  [self setNeedsDisplay:YES];
  [self setFrameSize:[mv displayFrame].size];
}

- (IBAction)promptClearWhiteboard:(id)sender
{
  [OKConfirmationDialog confirmationDialog:"Really clear the whiteboard?"
                        target:self
                        accept:@selector(clearWhiteboard:)
                        reject:nil
                        modalOn:[mv window]];
}

- (IBAction)clearWhiteboard:(id)sender
{
  [icon_hub deleteAtPath:[icon_hub path]+"/shapes"];
}

- (void)selectColor:(CPColor)color
{
  shape_attrs.color = [color hexString];
  var sv_iter = [setting_views objectEnumerator];
  var sv;
  while(sv = [sv_iter nextObject]){
    [sv setColor:color];
  }
}

- (void)selectThickness:(int)thickness
{
  shape_attrs.thickness = thickness * 1.0;
  var sv_iter = [setting_views objectEnumerator];
  var sv;
  while(sv = [sv_iter nextObject]){
    [sv setThickness:thickness * 1.0];
  }
}

- (void)drawRect:(CPRect)aRect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  CGContextSaveGState(context);
//    CGContextScaleCTM(context, [mv scaleFactor], [mv scaleFactor]);
    for(shape in shapes){
      var shape_type = shape_types[shapes[shape].type]
      if(shape_type == nil) { CPLog("Unknown Shape Type: %@", shapes[shape].type); }
      else { [shape_type drawShape:shapes[shape] mapView:mv]; }
    }
    var local_only_shape_iter = [local_only_shapes objectEnumerator];
    var local_only_shape;
    while(local_only_shape = [local_only_shape_iter nextObject]){
      CPLog("Drawing local shape: %@", local_only_shape);
      [local_only_shape.shape drawShape];
    }
    [pending_shape drawShape];
  CGContextRestoreGState(context);
}

@end
