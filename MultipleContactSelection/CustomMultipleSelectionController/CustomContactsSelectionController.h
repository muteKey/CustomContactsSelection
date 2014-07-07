//
//  CustomContactsSelectionController.h
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

typedef void(^SelectionCompletionBlock)(NSArray* selectedContacts);
typedef void(^SelectionCancelBlock)();

@interface CustomContactsSelectionController : UIViewController

@property (nonatomic, copy) SelectionCompletionBlock selectionCompletionBlock;
@property (nonatomic, copy) SelectionCancelBlock selectionCancelBlock;

@property (nonatomic, strong) UIImage* selectionImage;

@end
