//
//  RMTableViewCell.h
//  RMMapperExample
//
//  Created by Roomorama on 4/7/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic) IBOutlet UILabel *subLabel;

@end
