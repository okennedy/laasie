@implementation InstanceUserList : CPObject
{
  @outlet CPTableView managed_table;
  
  CPString filter_string;
  
  id users;
  id filtered_users;
}

- (id)initWithManagedTable:(CPTableView)in_managed_table
{
  if(self = [super init]){
    managed_table = in_managed_table;
    filter_string = nil;
    [self awakeFromCib];
  }
  return self;
}

- (void)awakeFromCib
{ 
  [self setUsers:[]];
  [managed_table setDataSource:self];
}

- (void)setUsers:(id)in_users
{
  users = in_users;
  [self filterUsers:filter_string];
  [managed_table reloadData];
}

- (id)users
{
  return users
}

- (void)controlTextDidChange:(id)sender
{
  [self filterUsers:[[sender object] stringValue]];
}

- (void)filterUsers:(CPString)string
{
  if(!string || string == ""){
    filtered_users = users;
    filter_string = nil;
  } else {
    filtered_users = [];
    for(i in users){
      if([users[i].nick hasPrefix:string]){
        filtered_users[filtered_users.length] = users[i];
      }
    }
    filter_string = string;
  }
  [managed_table reloadData];
}

- (void)addUser:(id)user
{
  users[users.length] = user;
  [self setUsers:users];
}

- (id)userForNick:(CPString)nick
{
  for(i in users){
    if(users[i].nick == nick){
      return users[i];
    }
  }
  return nil;
}

- (id)deleteSelectedUser
{
  var row = [managed_table selectedRow];
  if(row < 0){ return nil; }
//  CPLog("Deleting at %d", row);
  return [self deleteUserWithNick:filtered_users[row].nick]
}

- (id)deleteUserWithNick:(CPString)nick
{
  for(i in users){
    if(users[i].nick == nick){
      var ret = users.splice(i, 1)[0];
      [self setUsers:users];
      return ret;
    }
  }
  return nil;
}

- (int)numberOfRowsInTableView:(CPTableView)tv
{
//  CPLog("Asked to display %d users", filtered_users.length);
//  CPLog("Enumerating them: %@", [CPString JSONFromObject:filtered_users]);
  return filtered_users.length;
}

- (id)tableView:(CPTableView)tv 
      objectValueForTableColumn:(CPTableColumn)col
      row:(int)row
{
//  CPLog("Asked to show %d from %@ = %@", row, [CPString JSONFromObject:filtered_users], filtered_users[row].nick);
  return filtered_users[row].nick;
}

- (id)userNicks
{
  var ret = [];
  for(i in users){
    if(i == "isa"){ continue; }
    ret[ret.length] = users[i].nick;
  }
  return ret;
}

@end