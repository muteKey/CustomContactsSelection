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
@property (nonatomic, strong) NSMutableDictionary *items;
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
            
        }
    };
    
    ABAddressBookRequestAccessWithCompletion(addressBook,  completionHandler);
    [self.tableView reloadData];
}
- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
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
    
    
    NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];
    
    BOOL checked = [self.items[key] boolValue];
    self.items[key] = @(!checked);
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked"] : [UIImage imageNamed:@"checked"];
    
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
    id person = [self.contactsData objectAtIndex:indexPath.row];
    
    if (!checked) {
        
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
