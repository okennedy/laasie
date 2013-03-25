@implementation OKNumberField : CPControl
{
  CPStepper stepper;
  CPTextField field;
}

- (id)initWithFrame:(CPRect)aFrame
{
  if(self = [super initWithFrame:aFrame]){
    stepper = [[CPStepper alloc] initWithFrame:CPRectMakeZero()];
    [stepper setTarget:self];
    [stepper setAction:@selector(stepperUpdated:)];
    [stepper setMaxValue:Infinity];
    [stepper setMinValue:-Infinity];
    [stepper setValueWraps:NO];
    [self addSubview:stepper];    
    field = [[CPTextField alloc] initWithFrame:CPRectMakeZero()];
    [self addSubview:field];
    [field setTarget:self];
    [field setAction:@selector(fieldUpdated:)];
    [field setEditable:YES];
    [field setBezeled:YES];
    [field setBezelStyle:CPTextFieldRoundedBezel];
    [self layoutSubviews];
    [self stepperUpdated:stepper];
  }
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  var frame = [self frame];
  [stepper setFrame:CPRectMake(
    frame.size.width - 19, 2, 
    19, frame.size.height-2
  )];
  [field setFrame:CPRectMake(
    0, 0, 
    frame.size.width - 19, 
    frame.size.height
  )];
}

- (void)setIntegerValue:(int)i
{
  [self setFloatValue:i];
}
- (int)integerValue
{
  return Math.round([stepper floatValue]);
}
- (void)setIntValue:(int)i
{
  [self setFloatValue:i];
}
- (int)intValue
{
  return Math.round([stepper floatValue]);
}
- (void)setFloatValue:(float)f
{
  [stepper setFloatValue:f];
  [field setFloatValue:f];
}
- (int)floatValue
{
  return [stepper floatValue];
}
- (void)stepperUpdated:(id)sender
{
  [field setFloatValue:[stepper floatValue]];
  [self sendAction:[self action] to:[self target]];
}
- (void)fieldUpdated:(id)sender
{
  [stepper setFloatValue:[field floatValue]];
  [field setFloatValue:[stepper floatValue]];
  [self sendAction:[self action] to:[self target]];
}

- (void)setMinValue:(float)v
{
  [stepper setMinValue:v];
}

- (void)setMaxValue:(float)v
{
  [stepper setMinValue:v];
}

- (void)setIncrement:(float)v
{
  [stepper setIncrement:v];
}

@end