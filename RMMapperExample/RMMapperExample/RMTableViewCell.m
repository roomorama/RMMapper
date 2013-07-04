//
//  RMTableViewCell.m
//  RMMapperExample
//
//  Created by Roomorama on 4/7/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import "RMTableViewCell.h"

@implementation RMTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
