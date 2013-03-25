@implementation MVBackdrop : CPObject
{
  CPString internal_name;
  CPString name;
  CPImage image;
  CPRect position;
  id blackout;
  CPImageView battlemap_image;
  id delegate;
}

- (void)initWithSerialized:(id)serialized
{
  if(serialized.url == nil) { return nil; }
  if(self = [super init]){
    delegate = nil;
    internal_name = nil;
    battlemap_image = [[CPImageView alloc] initWithFrame:CPRectMakeZero()];
    position = CPRectMakeZero();
    [self update:serialized];
  }
  return self;
}

- (void)setDelegate:(id)in_delegate
{
  delegate = in_delegate;
}

- (id)delegate
{
  return delegate;
}

- (void)update:(id)serialized
{
  name = serialized.name || "Untitled Backdrop";
  if(!CPRectEqualToRect(position, serialized)){
    position = CPRectCreateCopy(serialized);
    if([delegate respondsToSelector:@selector(backdropMoved:)]){
      [delegate backdropMoved:self];
    }
  }
  if(![serialized.url isEqualToString:[image filename]]){
    image = [[CPImage alloc] initWithContentsOfFile:serialized.url
                             size:serialized.size];
    [battlemap_image setImage:image];
  }
  blackout = serialized.blackout;
}

- (void)delete
{
  if([delegate respondsToSelector:@selector(backdropDeleted:)]){
    [delegate backdropDeleted:self];
  }
}

- (CPString)name
{
  return name;
}

- (void)setInternalName:(CPString)in_internal_name
{
  internal_name = in_internal_name;
}

- (CPString)internalName
{
  return internal_name;
}

- (CPRect)position
{
  return position;
}

- (CPView)view
{
  return battlemap_image;
}

- (id)serialized
{
  return {
    "name"     : name,
    "url"      : [image filename],
    "origin"   : position.origin,
    "size"     : position.size,
    "blackout" : blackout
  };
}

@end