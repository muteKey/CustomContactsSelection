//
//  CustomContactsSelectionController.h
//  MultipleContactSelection
//
//  Created by Kirill on 2/13/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

typedef void(^ContactSelectionCompletionBlock)(NSArray *selectedContacts);

#import <UIKit/UIKit.h>

@interface CustomContactsSelectionController : UITableViewController
@property (nonatomic, copy) ContactSelectionCompletionBlock completionBlock;
@end
