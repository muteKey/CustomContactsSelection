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
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic) ABAddressBookRef addressBook;
@end

@implementation CustomContactsSelectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.items  = [NSMutableDictionary new];
    self.searchDisplayController.delegate                = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate   = self;
    
    [self addNavigationItems];
    
    CFErrorRef errorRef;
    self.addressBook = ABAddressBookCreateWithOptions(NULL, &errorRef);
    
    ABAddressBookRequestAccessCompletionHandler completionHandler = ^(bool granted, CFErrorRef error) {
        
        if (granted)
        {
            [self requestData];
        }
    };
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook,  completionHandler);

    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(appDidBecomeActive)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI actions -

- (void)addNavigationItems
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target: self
                                                                                           action: @selector(doneTapped)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelTapped)];
}

- (void)doneTapped
{
    if ([self.delegate respondsToSelector: @selector( didFinishSelectingContacts: )])
    {
        [self.delegate didFinishSelectingContacts: self.selectedContactsData];
    }
    
    //    [self dismissViewControllerAnimated: YES
    //                             completion: nil];
}

- (void)cancelTapped
{
    
    if ([self.delegate respondsToSelector:@selector( didCancelSelection )])
    {
        [self.delegate didCancelSelection];
    }
    
    //    [self dismissViewControllerAnimated: YES
    //                             completion: nil];
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
    ABRecordRef person;
    if (tableView == self.tableView)
    {
        person = (__bridge ABRecordRef)(self.contactsData[indexPath.row]);
    }
    else
    {
        person = (__bridge ABRecordRef)(self.filteredContactsData[indexPath.row]);
    }
    
    NSString *fullName = [self fullNameOfPerson: person];
    cell.textLabel.text = fullName;

    BOOL isChecked = [self.selectedContactsData containsObject: (__bridge id)(person)];
    UIImage *image = isChecked ? [UIImage imageNamed:@"checked"] : nil;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, 30, 30);
    button.frame = frame;
    
    [button setBackgroundImage: image
                      forState: UIControlStateNormal];
    
    // set the button's target so we can interpret touch events and map that to a NSIndexSet
    [button addTarget: self
               action: @selector( checkButtonTapped: event: )
     forControlEvents: UIControlEventTouchUpInside];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = button;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
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
  
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *key =cell.textLabel.text;
    NSLog(@"key=%@",key);
    BOOL checked = [self.items[key] boolValue];
    self.items[key] = @(!checked);
    
    
    UIButton *button = (UIButton *)cell.accessoryView;
    
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked"] : [UIImage imageNamed:@"checked"];
    
    [button setBackgroundImage:newImage forState:UIControlStateNormal];
    
    id person  = nil;
    if (tableView == self.tableView)
    {
        person = self.contactsData[indexPath.row];
        
        
    }
    else {
        person = self.filteredContactsData[indexPath.row];
        
    }
    
    if (!checked) {
        [self.selectedContactsData addObject:person];
    } else {
        [self.selectedContactsData removeObject:person];
    }

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
        
        if ([fullName rangeOfString: searchString
                            options: NSCaseInsensitiveSearch].location != NSNotFound)
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

#pragma mark - Data requesting -

- (void)requestData
{
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    self.contactsData = (__bridge NSArray*)people;
    [self sortContactsArray];
    
    [self.tableView reloadData];
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

- (void)sortContactsArray
{
    self.contactsData = [self.contactsData sortedArrayUsingComparator: ^NSComparisonResult(id obj1, id obj2) {
        
        ABRecordRef person1 = (__bridge ABRecordRef)(obj1);
        ABRecordRef person2 = (__bridge ABRecordRef)(obj2);
        
        NSString *firstSurname  = (__bridge_transfer NSString*)ABRecordCopyValue(person1, kABPersonLastNameProperty);
        NSString *secondSurname = (__bridge_transfer NSString*)ABRecordCopyValue(person2, kABPersonLastNameProperty);
        return [firstSurname compare: secondSurname];
        
    }];
}

#pragma mark - Notifications reaction -

- (void)appDidBecomeActive
{
    [self requestData];
}

@end
