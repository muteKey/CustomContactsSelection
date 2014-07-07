//
//  ViewController.m
//  MultipleContactSelection
//
//  Created by Kirill on 7/7/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "ViewController.h"
#import "CustomContactsSelectionController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectMultipleContactsTapped:(UIButton *)sender
{
    CustomContactsSelectionController* contactsSelectionVC = [[CustomContactsSelectionController alloc] init];
    contactsSelectionVC.selectionCompletionBlock = ^(NSArray* selectedContacts){
        NSLog(@"You have selected:\n");
        
        [selectedContacts enumerateObjectsUsingBlock:^(id personObject, NSUInteger idx, BOOL *stop) {

            ABRecordRef person = (__bridge ABRecordRef)(personObject);
            
            NSString *lastName  = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);

            NSLog(@"Person with first name: %@", firstName);
            NSLog(@"Person with last name: %@", lastName);
            NSLog(@"--------\n");
        }];
    };
    
    contactsSelectionVC.selectionCancelBlock = ^{
        NSLog(@"User canceled operation");
    };
    
    contactsSelectionVC.selectionImage = [UIImage imageNamed:@"customSelection.jpg"];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController: contactsSelectionVC];

    [self presentViewController: navController
                       animated: YES
                     completion: nil];
}

@end
