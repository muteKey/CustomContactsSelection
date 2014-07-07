//
//  CustomContactsSelectionController.m
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "CustomContactsSelectionController.h"

static   NSString * kNoNameString = nil;

@interface CustomContactsSelectionController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray        *contactsData;
@property (nonatomic, strong) NSMutableArray *filteredContactsData;
@property (nonatomic, strong) NSMutableArray *selectedContactsData;
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic) ABAddressBookRef addressBook;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation CustomContactsSelectionController

- (id)init
{
    if (self = [super initWithNibName: NSStringFromClass(self.class)
                               bundle: nil])
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.items  = [NSMutableDictionary new];
    
    
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
    
    [self adjustUI];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI actions -

- (void)setSelectionImage:(UIImage *)selectionImage
{
    if (selectionImage)
    {
        _selectionImage = selectionImage;
    }
}

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
    if (self.selectionCompletionBlock)
    {
        self.selectionCompletionBlock(self.selectedContactsData);
    }
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

- (void)cancelTapped
{
    if (self.selectionCancelBlock)
    {
        self.selectionCancelBlock();
    }
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

- (void)adjustUI
{
    if (!self.selectionImage)
    {
        self.selectionImage = [UIImage imageNamed:@"defaultSelectionImage.png"];
    }
}

#pragma mark - UitableViewDataSource -

- (NSInteger)tableView: (UITableView *)tableView
 numberOfRowsInSection: (NSInteger)section
{
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
    person = (__bridge ABRecordRef)(self.filteredContactsData[indexPath.row]);
    
    NSString *fullName = [self fullNameOfPerson: person];
    cell.textLabel.text = fullName;
    if ([fullName isEqualToString: kNoNameString])
    {
        cell.textLabel.textColor = [UIColor grayColor];
        [cell.textLabel setFont:[UIFont italicSystemFontOfSize:16.0]];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16.0]];
        
    }
    BOOL isChecked = [self.selectedContactsData containsObject: (__bridge id)(person)];
    UIImage *image = isChecked ? [UIImage imageNamed:@"checked"] : nil;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0,
                              0.0,
                              30.0,
                              30.0);
    button.frame = frame;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    [imageView setImage:image];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = imageView;
    
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
    CGPoint currentTouchPosition = [touch locationInView: self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    ABRecordRef personRecord = (__bridge ABRecordRef)(self.filteredContactsData[indexPath.row]);
    
    BOOL checked = [self.selectedContactsData containsObject: (__bridge id)(personRecord)];
    UIImage *newImage = (checked) ? [UIImage imageNamed:@"unchecked"] : [UIImage imageNamed:@"checked"];
    
    UIImageView * imageView = (UIImageView *)cell.accessoryView;
    [imageView setImage: newImage];
    
    id person  = nil;
    person = self.filteredContactsData[indexPath.row];
    
    if (!checked)
    {
        [self.selectedContactsData addObject:person];
    }
    else
    {
        [self.selectedContactsData removeObject:person];
    }
    
}

#pragma mark - UISearchBarDelegate -

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self.view endEditing:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
    {
        [self revertToBeginState];
        return;
    }
    
    [self.filteredContactsData removeAllObjects];
    for (id personObject in self.contactsData)
    {
        ABRecordRef person = (__bridge ABRecordRef)(personObject);
        NSString* fullName = [self fullNameOfPerson: person];
        
        if ([fullName rangeOfString: searchText
                            options: NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.filteredContactsData addObject: personObject];
        }
    }
    
    [self.tableView reloadData];
}

- (void)revertToBeginState
{
    
    [self.filteredContactsData removeAllObjects];
    [self.filteredContactsData addObjectsFromArray: self.contactsData];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    [self dismissKeyboard];
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
    
    [self revertToBeginState];
}

#pragma mark - Helpers -

- (void) dismissKeyboard
{
    [self.searchBar resignFirstResponder];
}

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
