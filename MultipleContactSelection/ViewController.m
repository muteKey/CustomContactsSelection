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
@end

@implementation ViewController

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
    
    cell.textLabel.text = fullName;
    return cell;
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




@end
