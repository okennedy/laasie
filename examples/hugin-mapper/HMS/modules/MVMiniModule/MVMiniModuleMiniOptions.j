@implementation MVMiniModuleMiniOptions : CPObject
{
  @outlet CPPopUpButton size;
  @outlet CPTextField name;
  @outlet CPWindow window;
  
  MVMiniModuleMini mini;
}

- (id)awakeFromCib
{
  [size removeAllItems];
  [size addItemWithTitle:"Medium"];
  [size addItemWithTitle:"Large"];
  [size addItemWithTitle:"Huge"];
  [size addItemWithTitle:"Gargantuan"];
  [size addItemWithTitle:"Colossal"];
}

- (IBAction)deleteMini:(id)sender
{
  CPLog("Delete");
  [mini delete];
  [window performClose:self];
}
- (IBAction)saveMini:(id)sender
{
  [mini internalDefinition].name = [name stringValue];
  [mini internalDefinition].size = [[size titleOfSelectedItem] uppercaseString];
  [mini saveMini];
  [window performClose:self];
}

- (void)startEditing:(MVMiniModuleMini)in_mini
{
  mini = in_mini;
  [size selectItemAtIndex:[mini size] - 1];
  [name setStringValue:[mini internalDefinition].name];
  [window makeKeyAndOrderFront:self];
  var pos = [mini screenPosition];
  var winFrame = [window frame];
  var screenFrame = [[window platformWindow] contentBounds];
  pos = CPPointMake(pos.x - 50, pos.y - 100);
  if(pos.x < 50){ pos.x = 50; }
  if(pos.y < 50){ pos.y = 50; }
  if(pos.x + winFrame.size.width > screenFrame.size.width - 50){ 
    pos.x = screenFrame.size.width - winFrame.size.width - 50; 
  }
  if(pos.y + winFrame.size.height > screenFrame.size.height - 50){ 
    pos.y = screenFrame.size.height - winFrame.size.height - 50; 
  }

  [window setFrameOrigin:pos];
}

@end