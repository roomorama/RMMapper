//
//  RMMasterViewController.m
//  RMMapperExample
//
//  Created by Roomorama on 28/6/13.
//  Copyright (c) 2013 Roomorama. All rights reserved.
//

#import "RMMasterViewController.h"
#import "RMDetailViewController.h"
#import "RMRoom.h"
#import "RMMapper.h"
#import "UIImageView+AFNetworking.h"
#import "RMTableViewCell.h"
#import "NSUserDefaults+RMSaveCustomObject.h"

@interface RMMasterViewController ()

// Contains all the rooms
@property (nonatomic, strong) NSMutableArray* rooms;

@end

@implementation RMMasterViewController

-(void)readData {
    // Get data from NSUserDefaults. If not available, read it from file and
    // save to NSUserDefaults
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.rooms = [defaults rm_customObjectForKey:@"SAVED_DATA"];
    
    if (!self.rooms) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"featured_destinations"
                                                         ofType:@"json"];
        
        // Update the rooms with onboard JSON
        NSData *theData = [NSData dataWithContentsOfFile:path];
        id responseJSON = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONReadingMutableContainers error:nil];
        id responseJSONResult = [responseJSON objectForKey:@"result"];
        self.rooms = [RMMapper mutableArrayOfClass:[RMRoom class]
                             fromArrayOfDictionary:responseJSONResult];
        
        [defaults rm_setCustomObject:self.rooms forKey:@"SAVED_DATA"];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self readData];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RMTableViewCell"];
    
    RMRoom* room = [self.rooms objectAtIndex:indexPath.row];
    [cell.imgView setImageWithURL:[NSURL URLWithString:room.thumbnail]];
    cell.mainLabel.text = room.title;
    cell.subLabel.text = [NSString stringWithFormat:@"%@, %@", room.city, room.country_code];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    RMDetailViewController* detailController = [storyBoard instantiateViewControllerWithIdentifier:@"RMDetailViewController"];
    RMRoom* room = [self.rooms objectAtIndex:indexPath.row];
    detailController.room = room;
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
