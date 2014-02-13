//
//  CustomContactsSelectionController.h
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomContactsSelectionDelegate <NSObject>

@optional
- (void)didFinishSelectingContacts: (NSArray *)contacts;
- (void)didCancelSelection;

@end

@interface CustomContactsSelectionController : UITableViewController

@property (nonatomic, weak) id<CustomContactsSelectionDelegate> delegate;

@end
