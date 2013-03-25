
@implementation MVMiniModuleProtoMini : CPView
{
  id mini_defn;
  id key;
  CPImageView image_view;
}

- (id)miniDefn
{
  return mini_defn;
}

- (void)setRepresentedObject:(id)in_mini_defn
{
  key = in_mini_defn.key;
  mini_defn = in_mini_defn.data;
  if(image_view == nil){
    image_view = [[CPImageView alloc] initWithFrame:CPRectInset([self bounds], 5, 5)];
    [image_view setImageScaling:CPScaleProportionally];
    [image_view setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [self addSubview:image_view];
  }
  
  //[self setBackgroundColor:[CPColor grayColor]];
  [image_view setImage:[MVMiniModule imageForMiniDefn:mini_defn]];
}

- (void)setSelected:(BOOL)isSelected
{
  [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

@end
