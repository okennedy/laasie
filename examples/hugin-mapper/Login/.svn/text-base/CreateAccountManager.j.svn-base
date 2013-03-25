@implementation CreateAccountManager : CPObject
{
  @outlet CPTextField username;
  @outlet CPTextField password;
  @outlet CPTextField confpass;
  
  @outlet CPTextField real_username;
  @outlet CPTextField real_password;
  
  @outlet CPTextField status;
  @outlet CPWindow window;
}

- (void)awakeFromCib
{
  [password setSecure:YES];
  [confpass setSecure:YES];
  [status setStringValue:""];
}

- (void)log:(CPString)msg
{
  CPLog("Account Management: %@", msg);
  [status setStringValue:msg];
}

- (IBAction)createAccount:(id)sender
{
  if([username stringValue] == ""){
    [self log:"No Username selected"];
    return;
  }
  if([password stringValue] == ""){
    [self log:"Password can not be empty"];
    return;
  }
  if([password stringValue] != [confpass stringValue]){
    [self log:"Passwords do not match"];
    return;
  }
  
  [self log:"Creating Account..."];

  var url = ICON_SERVER+"?"+
    "action=create_user&user="+[username stringValue]+
    "&password="+[password stringValue];
  
  var request = [[CPURLRequest alloc] initWithURL:url];
  [[CPURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
  [self log:"Error: Unable to connect to server (Reason:"+error+")"];
}

- (void)connection:(CPURLConnection)c didReceiveData:(CPString)data
{
  CPLog("Got account creation response %@", data);
  var obj = [data objectFromJSON];
  if(obj.result == "success"){
    [status setStringValue:""];
    [real_username setStringValue:[username stringValue]];
    [real_password setStringValue:[password stringValue]];
    [window performClose:self];
  } else {
    if(obj.reason == "File Exists"){
      [self log:"Error: Username already exists"];
    } else {
      [self log:"Error: " + obj.reason];
    }
  }
}
@end