@import <AppKit/CPView.j>
@import "toolmanager/MVToolManager.j"
@import "MVMenuManager.j"
//
@import "../modules/MVGridModule.j"
@import "../modules/MVMiniModule/MVMiniModule.j"
@import "../modules/MVWhiteboardModule/MVWhiteboardModule.j"
@import "../modules/MVZoneModule/MVZoneModule.j"
@import "../modules/MVInitiativeModule.j"
@import "../modules/MVSaveRestoreModule.j"
@import "../modules/MVBackdropModule/MVBackdropModule.j"
@import "../modules/MVIRCModule.j"

var GRID_MAP_MARKER_MARGIN = 30;

@implementation MapView : CPView
{
  int grid_size;
  CPPoint offset;
  CPArray modules;
  
  GridMarkerView grid_marker_view;
  CPView layout_view;  
  @outlet MVToolManager tool_manager;
  @outlet MVMenuManager menu_manager;
  
  CPDictionary drag_callbacks;
  
  ICON icon_hub;
}

- (void)init
{
  if(self = [super initWithFrame:CPRectMake(0,0, 100, 100)]){
    menu_manager = [[MVMenuManager alloc] init];
    tool_manager = [[MVToolManager alloc] initWithMapView:self 
                                              menuManager:menu_manager];
    grid_size = 50;
    offset = CPMakePoint(0,0);
    modules = [[CPArray alloc] init];
    icon_hub = nil;
    drag_callbacks = [[CPDictionary alloc] init];
    
    //While it follows the module schema for views... GridMarkerView
    //gets some special privs and needs to be specially instantiated.
    grid_marker_view = 
      [[GridMarkerView alloc] 
        initWithFrame:[self frame]
        margins:CPSizeMake(GRID_MAP_MARKER_MARGIN,
                           GRID_MAP_MARKER_MARGIN)];
    [modules addObject:grid_marker_view];
    [self addSubview:grid_marker_view];
    layout_view = [[CPView alloc] initWithFrame:CPRectMakeZero()];
    [self addSubview:layout_view];
    //[layout_view setBackgroundColor:[CPColor redColor]];
    [self layoutSubviews];
  }
  return self;
}

- (CPMenu)mainMenu
{
  return [menu_manager mainMenu];
}

- (id)installModule:(id)module
{
  CPLog("Installing %@", module);
  try {
    var module_info = [module mvModuleInfo];
    [modules addObject:module];
    
    if(module_info.tools){ [tool_manager installModule:module
                                         tools:module_info.tools]; }
    if(module_info.menu) { [menu_manager installModule:module
                                         menus:module_info.menu]; }
    if(module_info.view) { [layout_view addSubview:module_info.view]; }
    if(module_info.drags) { 
      for(var drag in module_info.drags){
        if(drag != "isa"){
          [drag_callbacks setObject:module forKey:module_info.drags[drag]];
        }
      }
      [self registerForDraggedTypes:
        [[self registeredDraggedTypes] 
          arrayByAddingObjectsFromArray:module_info.drags]];
    }
    
    if( (icon_hub != nil) &&
        [module respondsToSelector:@selector(mvSetICONHub:)]){
      [module mvSetICONHub:icon_hub];
    }
    
    if([module respondsToSelector:@selector(mvModuleInstalled)]){
      [module mvModuleInstalled];
    }
  } catch(err){
    if([module respondsToSelector:@selector(name)]){
      CPLog("Failed to install module %@: %@", [module name], err);
    } else {
      CPLog("Failed to install module %@: %@", module, err);
    }
  }
}

- (void)setICONHub:(ICON)hub
{
  icon_hub = hub;
  var moduleIter = [modules objectEnumerator];
  var module;
  while(module = [moduleIter nextObject]){
    if([module respondsToSelector:@selector(mvSetICONHub:)]){
      [module mvSetICONHub:icon_hub];
    }
  }
}

- (void)tryLoadModuleClass:(id)module_class
{
  [self tryLoadModuleClass:module_class settings:{}];
}

- (void)tryLoadModuleClass:(id)module_class settings:(id)settings
{
  try {
    var module =  [[module_class alloc] initWithMapView:self
                                        settings:settings];
    [self installModule:module];
  } catch(err){
    CPLog("Error initializing module %@: %@", module_class, err)
  }
}

- (void)updateModuleViews
{
  var view_rect = [self viewableRegion];
  var moduleIter = [modules objectEnumerator];
  var module;
  while(module = [moduleIter nextObject]){
    if([module respondsToSelector:@selector(mapViewUpdatedPosition:)]){
      [module mapViewUpdatedPosition:self];
    }
  }
  [self displayIfNeeded];
}

- (void)drawRect:(CGRect)aRect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  var i;
  CGContextSaveGState(context);
    CGContextSetStrokeColor(context, "black");
    CGContextSetLineWidth(2);
    CGContextStrokeRect(context, [layout_view frame]);
  CGContextRestoreGState(context);
}

- (void)mouseDown:(CPEvent)evt
{
  [[tool_manager activeTool] relayMouseDown:[self positionForEvent:evt]];
}

- (void)mouseDragged:(CPEvent)evt
{
  [[tool_manager activeTool] relayMouseDragged:[self positionForEvent:evt]];
}

- (void)mouseUp:(CPEvent)evt
{
  [[tool_manager activeTool] relayMouseUp:[self positionForEvent:evt]];
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
  var typeIter = [[[aSender draggingPasteboard] types] objectEnumerator];
  var type;
  var module;
  while(type = [typeIter nextObject]){
    if(module = [drag_callbacks objectForKey:type]){
      var drop_pos = 
        [layout_view convertPoint:[aSender draggingLocation]
                     fromView:[[self window] contentView]];
      [module mvModuleDragOperation:aSender 
              position:[self positionForPixel:drop_pos]];
    }
  }
}

- (void)layoutSubviews
{
  var baseFrame = 
    CPRectMake(0, 0, [self frameSize].width, [self frameSize].height);
  [grid_marker_view setFrame:baseFrame];
  [layout_view setFrame: 
    CPRectInset(baseFrame,
                GRID_MAP_MARKER_MARGIN,
                GRID_MAP_MARKER_MARGIN)];
  //CPLog("Layout view frame: %@", CPStringFromRect([layout_view frame]));
  [self updateModuleViews];
  [self setNeedsDisplay:YES];
}

//////////////////// MapView API

- (int)gridSize
{
  return grid_size;
}
- (void)setGridSize:(int)in_grid_size
{
  CPLog("Grid Size now %@", in_grid_size)
  grid_size = in_grid_size;
  [self updateModuleViews];
}

- (CPRect)displayFrame
{
  return CPRectMake(
    -offset.x * grid_size, -offset.y * grid_size, 
    [layout_view frameSize].width,
    [layout_view frameSize].height
  );
}

- (CPRect)viewableRegion
{
  return CPRectMake(
      offset.x, 
      offset.y, 
      ([layout_view frameSize].width)/grid_size,
      ([layout_view frameSize].height)/grid_size
    );
}

- (void)setViewableOriginToPosition:(CPPoint)pos
{
  offset.x = pos.x;
  offset.y = pos.y;
  [self updateModuleViews];
}

- (void)offsetViewableByPosition:(CPPoint)delta
{
  offset.x += delta.x;
  offset.y += delta.y;
  [self updateModuleViews];
}

- (void)offsetViewableByPixels:(CPPoint)delta
{
  offset.x += delta.x / (1.0*grid_size);
  offset.y += delta.y / (1.0*grid_size);
  [self updateModuleViews];
}

- (CPPoint)pixelForPosition:(CPPoint)pos
{
  return CPPointMake(
    (pos.x - offset.x) * grid_size,
    (pos.y - offset.y) * grid_size
  );
}

- (CPPoint)globalPixelForPosition:(CPPoint)pos
{
  return CPPointMake(pos.x * grid_size, pos.y * grid_size);
}

- (CPPoint)positionForPixel:(CPPoint)pix
{
  return CPPointMake(
    (pix.x / (1.0*grid_size)) + offset.x,
    (pix.y / (1.0*grid_size)) + offset.y
  );
}

- (CPSize)sizeFromPixelSize:(CPSize)pSize;
{
  return CPSizeMake(
    (pSize.width / (1.0*grid_size)),
    (pSize.height / (1.0*grid_size))
  )
}

- (CPSize)pixelSizeFromSize:(CPSize)size;
{
  return CPSizeMake(
    (size.width * (1.0*grid_size)),
    (size.height * (1.0*grid_size))
  )
}

- (CPRect)pixelRectFromRect:(CPRect)frame
{
  return { 
    origin : [self pixelForPosition:frame.origin],
    size   : [self pixelSizeFromSize:frame.size]
  };
}

- (CPRect)rectFromPixelRect:(CPRect)frame
{
  return { 
    origin : [self positionForPixel:frame.origin],
    size   : [self sizeFromPixelSize:frame.size]
  };
}

- (CPPoint)positionForEvent:(CPEvent)evt
{
  return [self positionForPixel:
            [layout_view convertPoint:[evt locationInWindow]
                         fromView:[[evt window] contentView]]
         ];
}

- (float)scaleFactor
{
  return [self gridSize] / 50.0;
}

@end

//@interface CPObject(MapViewModule)
//- (void)mapView:(MapView)mv 
//        moveToRect:(CPRect)targetRect 
//        gridSize:(int)squareWidth
//
//- (CPView)mvModuleView;
//
//- (CPArray:id)mvModuleTools;
//  \--> id -> {toolName, toolImage, mouseDownSel, mouseDragSel, mouseUpSel}
//@end

@implementation GridMarkerView : CPView
{
  CPArray horizontal_markers;
  CPArray vertical_markers;
  CPSize margins;
}

- (id)initWithFrame:(CGRect)aRect margins:(CPSize)in_margins
{
  if(self = [super initWithFrame:aRect]){
    [self setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
    horizontal_markers = [[CPArray alloc] init];
    vertical_markers = [[CPArray alloc] init];
    margins = in_margins;
  }
  return self;
}

- (void)updateMarkers:(BOOL)axisIsHorizontal targetRect:(CPRect)targetRect gridSize:(int)squareWidth
{
  var start, stop, offset, buffer;
  if(axisIsHorizontal){
    start = targetRect.origin.x;
    stop = targetRect.size.width;
    offset = margins.width;
    buffer = horizontal_markers;
  } else {
    start = targetRect.origin.y
    stop = targetRect.size.height;
    offset = margins.height
    buffer = vertical_markers;
  }
  
  offset = (Math.floor(start + 0.5) - start) * squareWidth
              + offset + (squareWidth / 2);
  stop = Math.floor(stop + start - 0.5);
  start = Math.floor(start + 0.5);
  
  for(var i = 0; i <= stop - start; i++){
    var marker;
    if([buffer count] <= i){
      marker = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
      [self addSubview:marker];
      [buffer addObject:marker];
    } else {
      marker = [buffer objectAtIndex:i];
    }
    [marker setStringValue:""+(i+start)];
    [marker sizeToFit];
    [marker setFrameOrigin:CPPointMake(
        axisIsHorizontal  ? offset + squareWidth * i 
                              - ([marker frameSize].width / 2)
                          : margins.width - 5 - [marker frameSize].width,
      (!axisIsHorizontal) ? offset + squareWidth * i
                              - ([marker frameSize].height / 2)
                          : margins.height - 5 - [marker frameSize].height
    )];
    //CPLog("" + [marker stringValue] + "@" + CPStringFromRect([marker frame]));
    [marker setHidden:NO];
  }
  for(; i < [buffer count]; i++){
    [[buffer objectAtIndex:i] setHidden:YES];
  }
}

- (void)mapViewUpdatedPosition:(MapView)mv
{
  var targetRect = [mv viewableRegion];
  var squareWidth = [mv gridSize];

  [self updateMarkers:YES targetRect:targetRect gridSize:squareWidth];
  [self updateMarkers:NO targetRect:targetRect gridSize:squareWidth];
}
@end
