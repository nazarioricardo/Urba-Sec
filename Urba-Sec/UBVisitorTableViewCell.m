//
//  UBVisitorTableViewCell.m
//  Urba-Sec
//
//  Created by Ricardo Nazario on 12/15/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBVisitorTableViewCell.h"

@implementation UBVisitorTableViewCell

- (IBAction)confirmPressed:(id)sender {
    
    [_delegate confirmVisitor:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_delegate listenToStatus:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
