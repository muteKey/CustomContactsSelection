#CustomContactsSelection
========================
This is class for custom multiple contacts selection from address book. You can specify selection completion block and cancel block. You need to **embed selection controller into navigation controller** to make things work properly. 

`    
	CustomContactsSelectionController* contactsSelectionVC =	 [[CustomContactsSelectionController alloc] init];
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
                     completion: nil]; `
