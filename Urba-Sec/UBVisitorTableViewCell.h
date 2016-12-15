//
//  UBVisitorTableViewCell.h
//  Urba-Sec
//
//  Created by Ricardo Nazario on 12/15/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBVisitorTableViewCell;

@protocol VisitorCellDelegate <NSObject> //this delegate is fired each time you tap the cell

-(void)confirmVisitor:(UBVisitorTableViewCell *)cell;
-(void)listenToStatus:(UBVisitorTableViewCell *)cell;

@end

@interface UBVisitorTableViewCell : UITableViewCell

@property(weak, nonatomic) id <VisitorCellDelegate> delegate; //defining the delegate

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) NSString *visitorId;


@end
