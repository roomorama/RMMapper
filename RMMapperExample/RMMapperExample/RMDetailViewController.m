//
//  RMDetailViewController.m
//  RMMapperExample
//
//  Created by Roomorama on 28/6/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import "RMDetailViewController.h"

@interface RMDetailViewController ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UILabel *hostLabel;
@property (strong, nonatomic) IBOutlet UILabel *certifiedLabel;

@end

@implementation RMDetailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self display];
}

-(void)display {
    if (!self.room) {
        return;
    }
    self.titleLabel.text = self.room.title;
    self.typeLabel.text = self.room.type;
    self.rateLabel.text = [NSString stringWithFormat:@"%@ %@",
                           self.room.currency_code,
                           self.room.price];
    self.hostLabel.text = self.room.host.display;
    self.certifiedLabel.text = [self.room.host.certified stringValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
