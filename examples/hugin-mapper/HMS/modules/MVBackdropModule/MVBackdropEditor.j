@import "../../OKNumberField.j"

@implementation MVBackdropEditor : CPPanel
{
  CPImageView backdrop_image;
  MVBackdropGrid backdrop_grid;
  CPScrollView scroller;
  CPString internal_name;
  CPImage image;
  BOOL loaded;
  
  OKNumberField scale_stepper; 
  OKNumberField x_stepper; 
  OKNumberField y_stepper; 
  
  CPTextField name;
  
  id delegate;
}

- (void)initWithImage:(CPImage)in_image
{
  if(self = [super initWithContentRect:CPRectMake(300,100,600,410)
                             styleMask:CPTitledWindowMask |
                                       CPClosableWindowMask |
                                       CPResizableWindowMask]){
    scroller =
      [[CPScrollView alloc] initWithFrame:CPRectMake(0, 0, 600, 300)];
    [scroller setAutoresizingMask:CPViewWidthSizable |
                                  CPViewHeightSizable];
    [[self contentView] addSubview:scroller];
    backdrop_grid = 
      [[MVBackdropGrid alloc] initWithFrame:CPRectMakeZero()];

    var tmp;
    tmp = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [tmp setStringValue:"Pixels/Square:"];
    [tmp sizeToFit];
    [tmp setFrameOrigin:CPPointMake(10, 315)];
    [tmp setAutoresizingMask:CPViewMaxXMargin |
                             CPViewMinYMargin];
    [[self contentView] addSubview:tmp];

    tmp = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [tmp setStringValue:"X Offset:"];
    [tmp sizeToFit];
    [tmp setFrameOrigin:CPPointMake(10, 345)];
    [tmp setAutoresizingMask:CPViewMaxXMargin |
                             CPViewMinYMargin];
    [[self contentView] addSubview:tmp];

    tmp = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [tmp setStringValue:"Y Offset:"];
    [tmp sizeToFit];
    [tmp setFrameOrigin:CPPointMake(10, 375)];
    [tmp setAutoresizingMask:CPViewMaxXMargin |
                             CPViewMinYMargin];
    [[self contentView] addSubview:tmp];
    
    tmp = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [tmp setStringValue:"Backdrop Name:"];
    [tmp sizeToFit];
    [tmp setFrameOrigin:CPPointMake(180, 316)];
    [tmp setAutoresizingMask:CPViewMaxXMargin |
                             CPViewMinYMargin];
    [[self contentView] addSubview:tmp];
    
    tmp = [[CPButton alloc] initWithFrame:CPRectMake(485, 370, 100, 24)];
    [tmp setTitle:"Save"];
    [tmp setTarget:self];
    [tmp setAction:@selector(saveButton:)];
    [tmp setAutoresizingMask:CPViewMinXMargin |
                             CPViewMinYMargin];
    [[self contentView] addSubview:tmp];
    
    scale_stepper = 
      [[OKNumberField alloc] initWithFrame:CPRectMake(90, 310, 80, 30)];
    [scale_stepper setTarget:backdrop_grid];
    [scale_stepper setAction:@selector(takeScaleFrom:)];
    [scale_stepper setMinValue:1];
    [scale_stepper setAutoresizingMask:CPViewMaxXMargin |
                                       CPViewMinYMargin];
    [[self contentView] addSubview:scale_stepper];
    
    x_stepper = 
      [[OKNumberField alloc] initWithFrame:CPRectMake(90, 340, 80, 30)];
    [x_stepper setTarget:backdrop_grid];
    [x_stepper setAction:@selector(takeXOffsetFrom:)];
    [x_stepper setIncrement:0.1];
    [x_stepper setAutoresizingMask:CPViewMaxXMargin |
                                   CPViewMinYMargin];
    [[self contentView] addSubview:x_stepper];

    y_stepper = 
      [[OKNumberField alloc] initWithFrame:CPRectMake(90, 370, 80, 30)];
    [y_stepper setTarget:backdrop_grid];
    [y_stepper setAction:@selector(takeYOffsetFrom:)];
    [y_stepper setIncrement:0.1];
    [y_stepper setAutoresizingMask:CPViewMaxXMargin |
                                   CPViewMinYMargin];
    [[self contentView] addSubview:y_stepper];
    
    name = 
      [[CPTextField alloc] initWithFrame:CPRectMake(280, 310, 310, 30)];
    [name setBezeled:YES];
    [name setBezelStyle:CPTextFieldSquareBezel];
    [name setEditable:YES];
    [name setAutoresizingMask:CPViewWidthSizable |
                              CPViewMinYMargin];
    [[self contentView] addSubview:name];

    image = in_image;
    [image setDelegate:self];
    backdrop_image = [[CPImageView alloc] initWithFrame:CPRectMakeZero()];
    [scroller setDocumentView:backdrop_image];
//    [image load];
    [backdrop_image setImageScaling:CPScaleNone];
    [backdrop_image setImage:image];
    [backdrop_image addSubview:backdrop_grid];
    [self updateEditorLayout];
    loaded = YES;
  }
  return self;
}

- (void)initWithObject:(id)serialized internalName:(CPString)in_internal_name
{
  if((serialized == nil) || 
     (serialized.url == nil)) { return nil; }
  var in_image = [[CPImage alloc] initWithContentsOfFile:serialized.url];
  if(self = [self initWithImage:in_image]){
    internal_name = in_internal_name;
    [backdrop_grid setImageSize:serialized.size];
    [backdrop_grid setImagePosition:serialized.origin];
    [name setStringValue:(serialized.name || "Untitled Backdrop")];
  }
  return self;
}

- (void)imageDidLoad:(CPImage)in_image
{
  [image setDelegate:nil];
  [self updateEditorLayout];
}

- (void)updateEditorLayout
{
  [backdrop_image setFrameOrigin:CPPointMake(0,0)];
  if([image loadStatus] == CPImageLoadStatusCompleted){
    [backdrop_image setFrameSize:[image size]];
  }
  [backdrop_grid setFrame:[backdrop_image frame]];
  [scale_stepper setFloatValue:[backdrop_grid pixPerSquare]];
  [x_stepper setFloatValue:[backdrop_grid imagePosition].x];
  [y_stepper setFloatValue:[backdrop_grid imagePosition].y];
}

- (id)serialized
{
  return {
    "name" : [name stringValue],
    "url" : [image filename],
    "origin" : [backdrop_grid imagePosition],
    "size"   : [backdrop_grid imageSize],
    "blackout" : [backdrop_grid blackout]
  };
}

- (CPString)internalName
{
  return internal_name;
}

- (IBAction)saveButton:(id)sender
{
  if([delegate respondsToSelector:@selector(backdropEditorSaved:)]){
    [delegate backdropEditorSaved:self];
  } else {
    CPLog("Would have saved: %@", [CPString JSONFromObject:[self serialized]]);
  }
}

- (void)setDelegate:(id)in_delegate
{
  delegate = in_delegate;
}

- (id)delegate
{
  return delegate;
}

@end

@implementation MVBackdropGrid : CPView
{
  CPPoint line_count;
  CPSize image_size;
  CPPoint image_position;
}

- (IBAction)takeScaleFrom:(CPControl)sender
{
  var pix_per_square = [sender floatValue];
  var frame_size = [self frameSize];
  
  image_size = CPSizeMake(frame_size.width / pix_per_square,
                          frame_size.height / pix_per_square);

  line_count.x = Math.ceil(image_size.width) + 1;
  line_count.y = Math.ceil(image_size.height) + 1;
  [self setNeedsDisplay:YES];
}
- (float)pixPerSquare
{
  if(image_size == nil) { return 1337; }
  return [self frameSize].width / image_size.width;
}

- (IBAction)takeXOffsetFrom:(CPControl)sender
{
  image_position.x = [sender floatValue];
  [self setNeedsDisplay:YES];
}
- (IBAction)takeYOffsetFrom:(CPControl)sender
{
  image_position.y = [sender floatValue];
  [self setNeedsDisplay:YES];
}

- (void)setImagePosition:(CPPoint)in_pos
{
  image_position = CPPointCreateCopy(in_pos);
}

- (CPPoint)imagePosition
{
  return CPPointCreateCopy(image_position);
}

- (void)setImageSize:(CPSize)in_size
{
  image_size = CPSizeCreateCopy(in_size);
}

- (CPSize)imageSize
{
  return CPSizeCreateCopy(image_size);
}

- (CPArray)blackout
{
  return [];
}

- (void)layoutSubviews
{
  line_count.x = Math.ceil(image_size.width) + 1;
  line_count.y = Math.ceil(image_size.height) + 1;
}

- (void)drawRect:(CPRect)displayRect
{
  var context = [[CPGraphicsContext currentContext] graphicsPort];
  var i;
  
  var scale = CPPointMake(
    [self frameSize].width / image_size.width,
    [self frameSize].height / image_size.height
  );
  var offset = CPPointMake(
    - image_position.x * scale.x,
    - image_position.y * scale.y
  );
  
  CGContextSaveGState(context);
    CGContextSetStrokeColor(context, "grey");
    CGContextSetLineWidth(1);
    
    for(i = 0; i <= line_count.x; i++){
      CGContextStrokeRect(
        context,
        CPRectMake(i * scale.x+offset.x, 0, 0, [self frameSize].height)
      );
    }
    for(i = 0; i <= line_count.y; i++){
      CGContextStrokeRect(
        context,
        CPRectMake(0, i * scale.y+offset.y, [self frameSize].width, 0)
      );
    }
  CGContextRestoreGState(context);
}

- (id)initWithFrame:(CPRect)aFrame
{
  if([super initWithFrame:aFrame]){
    image_size = CPSizeMake(3,3);
    image_position = CPPointMake(0,0)
    line_count = CPPointMake(4,4);
  }
  return self;
}

@end