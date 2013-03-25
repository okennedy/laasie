@implementation EditAccountManager : CPObject {
  @outlet CPTextField username;
  @outlet CPTextField old_password;
  @outlet CPTextField new_password;
  @outlet CPTextField dup_password;
  @outlet CPWindow    account_window;
  @outlet CPTextField email;
  
  ICON icon;
}

- (IBAction)updatePassword:(id)sender
{
  if(![[new_password stringValue] isEqualToString:
       [dup_password stringValue]]){
    var alert = 
      [CPAlert alertWithError:
        "The passwords do not match"];
    [alert beginSheetModalForWindow:account_window];
    return;
  }
  var error;
  if(error = [icon updatePasswordFrom:[old_password stringValue]
                                   to:[new_password stringValue]]){
    var alert = 
      [CPAlert alertWithError:
        [CPString stringWithFormat:"Error updating password: %@", error]];
    [alert beginSheetModalForWindow:account_window];
  } else {
    var alert = 
      [CPAlert alertWithError:
        "Successfully updated passwords"];
    [old_password setStringValue:""];
    [new_password setStringValue:""];
    [dup_password setStringValue:""];
    [alert beginSheetModalForWindow:account_window];
  }
}

- (IBAction)updateContactInfo:(id)sender
{
  [icon immediateWriteToPath:"/users/"+[icon username]+"/email"
        data:[email stringValue]];
  var alert = 
    [CPAlert alertWithError:
      "Successfully updated contact information"];
  [alert beginSheetModalForWindow:account_window];
}

- (void)awakeFromCib
{
  [username setEnabled:NO];
}

- (void)editAccountWithIcon:(ICON)in_icon
{
  icon = in_icon;
  [username setStringValue:[icon username]];
  var userinfo = [icon readUserInfo];
  
  [old_password setStringValue:""];
  [new_password setStringValue:""];
  [dup_password setStringValue:""];
  
  [email setStringValue:(userinfo.email || "")];

  [account_window makeKeyAndOrderFront:self];
}

@end