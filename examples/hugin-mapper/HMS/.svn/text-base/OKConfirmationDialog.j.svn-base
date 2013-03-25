@implementation OKConfirmationDialog : CPObject
{
  CPInvocation default_invocation;
  CPInvocation other_invocation;
  id context;
}

- (id)initWithMessage:(CPString)msg
      default:(CPString)default_msg
      other:(CPString)other_msg
      target:(id)target
      defaultSel:(SEL)default_selector
      otherSel:(SEL)other_selector
{
  if(self = [super init]){
    alert = [CPAlert alertWithMessageText:msg
                     defaultButton:default_msg
                     alternateButton:other_msg
                     otherButton:nil
                     informativeTextWithFormat:nil];
    [alert setDelegate:self];
    
    if(default_selector){
      default_invocation = [[CPInvocation alloc] initWithMethodSignature:nil];
      [default_invocation setTarget:target];
      [default_invocation setSelector:default_selector];
      [default_invocation setArgument:self atIndex:2];
    } else {
      default_invocation = nil;
    }

    if(other_selector){
      other_invocation = [[CPInvocation alloc] initWithMethodSignature:nil];
      [other_invocation setTarget:target];
      [other_invocation setSelector:other_selector];
      [other_invocation setArgument:self atIndex:2];
    } else {
      other_invocation = nil;
    }
  }
  return self;
}

- (void)alertDidEnd:(CPAlert)alert returnCode:(int)code
{
  if(code){
    [other_invocation invoke];
  } else {
    [default_invocation invoke];
  }
}

- (id)context
{
  CPLog("Context: %@", context);
  return context;
}

- (void)setContext:(id)in_context
{
  context = in_context;
  CPLog("Set Context: %@", context);
}

- (void)openAsSheetForWindow:(CPWindow)window
{
  [alert runModal];
}

- (void)runModal
{
  [alert runModal];
}

+ (void)confirmationDialog:(CPString)msg
        target:(id)target
        accept:(SEL)default_selector
        reject:(SEL)other_selector
{
  return [OKConfirmationDialog confirmationDialog:msg
                               target:target
                               accept:default_selector
                               reject:other_selector
                               modalOn:nil];
}

+ (void)confirmationDialog:(CPString)msg
        target:(id)target
        accept:(SEL)default_selector
        reject:(SEL)other_selector
        modalOn:(CPWindow)window
{
  var dialog =
    [[OKConfirmationDialog alloc]
      initWithMessage:msg
      default:"Cancel"
      other:"OK"
      target:target
      defaultSel:other_selector
      otherSel:default_selector];
  [dialog openAsSheetForWindow:window];
  return dialog;
}

+ (void)confirmationDialog:(CPString)msg
        yes:(CPString)yes
        no:(CPString)no
        target:(id)target
        accept:(SEL)default_selector
        reject:(SEL)other_selector
        modalOn:(CPWindow)window
{
  var dialog =
    [[OKConfirmationDialog alloc]
      initWithMessage:msg
      default:no
      other:yes
      target:target
      defaultSel:other_selector
      otherSel:default_selector];
  [dialog openAsSheetForWindow:window];
  return dialog;
}
@end