@implementation AccountManager : CPObject
{
  @outlet CPTextField username;
  @outlet CPTextField password;
  @outlet CPTextField confirm;
  @outlet CPTextField log;
  @outlet CPWindow window;
  
  @outlet CPTextField primary_username;
  
}

- (void)awakeFromCib
{
  [log setStringValue:""];
}

- (void)log:(CPString)msg
{
  CPLog("Account Management: %@", msg);
  [log setStringValue:msg];
}

- (IBAction)createAccount:(id)sender
{
  if([username stringValue] == ""){
    [self log:"Choose a Username"];
    return;
  }
  if([password stringValue] == ""){
    [self log:"Choose a Password"];
    return;
  }
  if([password stringValue] != [confirm stringValue]){
    [self log:"Passwords do not match"];
    return;
  }

  [self log:"Creating Account..."];
  var account_info = {"password" : [password stringValue]}

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
  CPLog("Got %@", data);
  var obj = [data objectFromJSON];
  if(obj.result == "success"){
    [log setStringValue:""];
    [primary_username setStringValue:[username stringValue]];
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