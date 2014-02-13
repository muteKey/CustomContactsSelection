//
//  ViewController.m
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface ViewController ()
@property (nonatomic, strong) NSArray *contactsData;
@property (nonatomic, strong) NSMutableSet *selectedPeople;
@end

@implementation ViewController

- (NSMutableSet *) selectedPeople {
    if (_selectedPeople == nil) {
        _selectedPeople = [[NSMutableSet alloc] init];
    }
    return _selectedPeople;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CFErrorRef errorRef;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &errorRef);
    
    ABAddressBookRequestAccessCompletionHandler completionHandler = ^(bool granted, CFErrorRef error) {

                                            if (granted)
                                            {
                                                CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
                                                self.contactsData = (__bridge NSArray*)people;
                                                
                                                NSLog(@"Contact object: %@", [self.contactsData.firstObject class]);
                                                [self.tableView reloadData];
                                            }
    };
    
    ABAddressBookRequestAccessWithCompletion(addressBook,  completionHandler);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - uitableViewdataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    ABRecordRef person = (__bridge ABRecordRef)(self.contactsData[indexPath.row]);
    NSString *fullName = [self fullNameOfPerson: person];
    
  


    NSMutableDictionary *item = [self.contactsData objectAtIndex:indexPath.row];
    [item setObject:cell forKey:@"cell"];
    
    BOOL checked = [[item objectForKey:@"checked"] boolValue];
    UIImage *image = (checked) ? [UIImage imageNamed:@"checked"] : [UIImage imageNamed:@"unchecked"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    button.frame = frame;   // match the button's size with the image size
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    cell.textLabel.text = fullName;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *item = [self.contactsData objectAtIndex:indexPath.row];
    
    BOOL checked = [[item objectForKey:@"checked"] boolValue];
    
    [item setObject:[NSNumber numberWithBool:!checked] forKey:@"checked"];
    
    UITableViewCell *cell = [item objectForKey:@"cell"];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked"] : [UIImage imageNamed:@"checked"];
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    id person = [self.contactsData objectAtIndex:indexPath.row];
    if (checked) {
      
        [self.selectedPeople addObject:person];
    } else {
        [self.selectedPeople removeObject:person];
    }
    NSLog(@"%@", self.selectedPeople);
}


#pragma mark - Helpers -

- (NSString *) fullNameOfPerson:(ABRecordRef)person {
    NSString * fname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString * mname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    NSString * lname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableString * fullName = [NSMutableString string];
    if(fname.length > 0)
    {
        [arr addObject: fname];
    }
    if(mname.length > 0)
    {
        [arr addObject:mname];
    }
    if(lname.length > 0)
    {
        [arr addObject:lname];
    }
    
    for (int i = 0; i < arr.count; i++)
    {
        if (i == 0)
        {
            [fullName appendString:arr[i]];
        }
        else
        {
            [fullName appendString: @" "];
            [fullName appendString: arr[i]];
        }
    }
    return fullName;
}
- (IBAction)doneButtonTapped:(id)sender {
}


- (IBAction)cancelButtonTapped:(id)sender {
}



@end
