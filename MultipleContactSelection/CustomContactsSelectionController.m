//
//  CustomContactsSelectionController.m
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "CustomContactsSelectionController.h"
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

@interface CustomContactsSelectionController ()<UISearchDisplayDelegate>

@property (nonatomic, strong) NSArray        *contactsData;
@property (nonatomic, strong) NSMutableArray *filteredContactsData;
@property (nonatomic, strong) NSMutableArray *selectedContactsData;

@end

@implementation CustomContactsSelectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchDisplayController.delegate                = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate   = self;
   
    CFErrorRef errorRef;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &errorRef);
    
    ABAddressBookRequestAccessCompletionHandler completionHandler = ^(bool granted, CFErrorRef error) {
        
        if (granted)
        {
            CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
            self.contactsData = (__bridge NSArray*)people;
            
            [self.tableView reloadData];
        }
    };
    
    ABAddressBookRequestAccessWithCompletion(addressBook,  completionHandler);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UitableViewDataSource -

- (NSInteger)tableView: (UITableView *)tableView
 numberOfRowsInSection: (NSInteger)section
{
    if (tableView == self.tableView)
    {
        return self.contactsData.count;
    }
    
    return self.filteredContactsData.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                      reuseIdentifier: cellIdentifier];
    }
    
    if (tableView == self.tableView)
    {
        ABRecordRef person = (__bridge ABRecordRef)(self.contactsData[indexPath.row]);
        NSString *fullName = [self fullNameOfPerson: person];

        cell.textLabel.text = fullName;
        return cell;
    }
    
    ABRecordRef person = (__bridge ABRecordRef)(self.filteredContactsData[indexPath.row]);
    NSString *fullName = [self fullNameOfPerson: person];
    
    cell.textLabel.text = fullName;

    return cell;
}


#pragma mark - UISearchDisplayDelegate -
-(BOOL)searchDisplayController:       (UISearchDisplayController *)controller
    shouldReloadTableForSearchString: (NSString *)searchString
{
    [self.filteredContactsData removeAllObjects];
    for (id personObject in self.contactsData)
    {
        ABRecordRef person = (__bridge ABRecordRef)(personObject);
        NSString* fullName = [self fullNameOfPerson: person];
        
        if ([fullName rangeOfString: searchString].location != NSNotFound)
        {
            [self.filteredContactsData addObject: personObject];
        }
    }
    
    return YES;
}

#pragma mark - Getters -

- (NSMutableArray *)filteredContactsData
{
    if (!_filteredContactsData)
    {
        _filteredContactsData = [NSMutableArray new];
    }
    
    return _filteredContactsData;
}

- (NSMutableArray *)selectedContactsData
{
    if (!_selectedContactsData)
    {
        _selectedContactsData = [NSMutableArray new];
    }
    
    return _selectedContactsData;
}

#pragma mark - Helpers -

- (NSString *) fullNameOfPerson:(ABRecordRef)person
{
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
