var MVMiniModuleMiniSize = {
  MEDIUM     : 1,
  LARGE      : 2,
  HUGE       : 3,
  GARGANTUAN : 4,
  COLOSSAL   : 6
};


@implementation MVMiniModuleMini : CPObject
{
  MVMiniModuleMiniView mini_view;
  id mini_defn;
  id delegate;
  CPString internal_name;
  MVMiniModule mm;
  CPPoint moving;
}

- (id)initWithMiniDefn:(id)in_mini_defn 
      miniModule:(MVMiniModule)in_mm
      internalName:(CPString)in_internal_name
{
  if(self = [super init]){
    mm = in_mm;
    mini_view = nil;
    mini_defn = in_mini_defn;
    delegate = nil;
    moving = nil;
    internal_name = in_internal_name;
  }
  return self;
}

- (void)startEditing
{
  [[mm miniEditor] startEditing:self];
}

- (void)startMove
{
  moving = CPPointMake(mini_defn.x, mini_defn.y);
}

- (void)dragMove:(CPEvent)evt
{
  moving = [[mm mapView] positionForEvent:evt];
  moving.x -= 0.5 * [self size]; 
  moving.y -= 0.5 * [self size];

  var nearest = CPPointMake(Math.floor(moving.x+0.5), 
                            Math.floor(moving.y+0.5));
  if((Math.abs(moving.x - nearest.x)  < 0.1)&&
     (Math.abs(moving.y - nearest.y) < 0.1)){
    moving = nearest;
  }

  var pix = [[mm mapView] pixelForPosition:moving];
  pix.x += 2;
  pix.y += 2;
  
  [mini_view setFrameOrigin:pix];
}

- (void)commitMove
{
  if([self setPosition:moving]){
    [self saveMini];
  }
  moving = nil;
}

- (void)saveMini
{
  CPLog("Saving mini: %@", internal_name);
  [mm saveMini:self];
}

- (void)localDelete
{
  [[mm mapMinis] removeObjectForKey:[self internalName]];
  [self localDeleteWithoutCleaning]
}
- (void)localDeleteWithoutCleaning
{
  CPLog("Cleaning up mini %@", internal_name);
  [[mini_view superview] display];
  [mini_view removeFromSuperview];
}

- (void)delete
{
  [[mm iconHub] deleteAtPath:[[mm iconHub] path]+"/minis/"+internal_name];

}

- (BOOL)setPosition:(CPPoint)position
{
  if((mini_defn.x != position.x)||
     (mini_defn.y != position.y)){
    mini_defn.x = position.x;
    mini_defn.y = position.y;
    return YES;
  } else {
    return NO;
  }
}

- (id)delegate
{
  return delegate;
}
- (void)setDelegate:(id)in_delegate
{
  delegate = in_delegate;
}

- (void)setInternalDefinition:(id)in_mini_defn
{
  mini_defn = in_mini_defn;
  [[[self view] imageView] setImage:[MVMiniModule imageForMiniDefn:mini_defn]];
  [[self view] setTitle:mini_defn.name];
  [self updateView];
}

- (int)size
{
  if(mini_defn.size == undefined){
    return 1;
  }
  if(MVMiniModuleMiniSize[mini_defn.size] == undefined){
    return mini_defn.size * 1;
  }
  return MVMiniModuleMiniSize[mini_defn.size];
}

- (CPPoint)screenPosition
{
  return [mini_view frameOrigin];
}

- (void)updateView
{
  var size = [self size]
  var target_size = CPSizeMake(50 * size, 50 * size);
  if(mm && (moving == nil)){
    var target_point = 
      [[mm mapView] pixelForPosition:CPPointMake(mini_defn.x, mini_defn.y)];
    target_point.x += 2;
    target_point.y += 2;
    [mini_view setFrameOrigin:target_point];
    target_size.width *= [[mm mapView] scaleFactor];
    target_size.height *= [[mm mapView] scaleFactor];
  }
  target_size.width -= 4;
  target_size.height -= 4;
  [mini_view setFrameSize:target_size];
}

- (CPImageView)view
{
  if(mini_view == nil){
    mini_view = [[MVMiniModuleMiniView alloc] initWithFrame:CPRectMakeZero()];
    [[mini_view imageView] setBackgroundColor:[CPColor whiteColor]];
    [[mini_view imageView] setImageScaling:CPScaleProportionally];
    [[mini_view imageView] setImage:[MVMiniModule imageForMiniDefn:mini_defn]];
    [mini_view setBaseMini:self];
    [self updateView];
  }
  return mini_view;
}

- (CPString)internalName
{
  return internal_name;
}
- (id)internalDefinition
{
  return mini_defn;
}

@end

@implementation MVMiniModuleMiniView : CPView
{
  MVMiniModuleMini mini;
  BOOL single_click;
  CPView subtitle_view;
  CPImageView image_view;
}

- (void)setBaseMini:(MVMiniModuleMini)in_mini
{
  mini = in_mini;
  [self setTitle:[mini internalDefinition].name];
}

- (CPImageView)imageView
{
  if(image_view == nil){
    image_view = [[CPImageView alloc] initWithFrame:CPRectMakeZero()];
    [self addSubview:image_view];
  }
  return image_view;
}

- (void)setTitle:(CPString)title
{
  if(subtitle_view == nil){
    subtitle_view = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [subtitle_view setFont:[CPFont systemFontOfSize:8]];
    [subtitle_view setBackgroundColor:
      [[CPColor whiteColor] colorWithAlphaComponent:0.8]];
    [self addSubview:subtitle_view];
  }
  [subtitle_view setStringValue:title];
  [subtitle_view sizeToFit];
  [self layoutSubviews];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  if(image_view){
    [image_view setFrame:CPRectInset([self frame], 2, 2)];
    [image_view setFrameOrigin:CPPointMake(2,2)];
  }
  if(subtitle_view){
    [subtitle_view setFrameOrigin:
      CPPointMake(Math.max([self frameSize].width - 0.5 -
                           [subtitle_view frameSize].width, 0),
                  Math.max([self frameSize].height - 0.5 -
                           [subtitle_view frameSize].height, 0))];
  }
}

- (void)mouseDown:(CPEvent)evt
{ 
  single_click = NO;
  switch([evt clickCount]){
    case 1: 
      single_click = YES;
      [mini startMove];
      break;
    case 2:
      [mini startEditing];
      break;
  }
}

- (void)mouseDragged:(CPEvent)evt
{
  if(single_click){
    [mini dragMove:evt];
  }
}

- (void)mouseUp:(CPEvent)evt
{
  if(single_click){
    [mini commitMove];
  }
}

- (void)drawRect:(CPRect)aRect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  CGContextSaveGState(context);
    [[CPColor whiteColor] setFill];
    CGContextFillRect(context, aRect);
    [[CPColor grayColor] setFill];
    CGContextSetLineWidth(2);
    CGContextStrokeRect(context, aRect);
  CGContextRestoreGState(context);
  [super drawRect:aRect];
}

@end