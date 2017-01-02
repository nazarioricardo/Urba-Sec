//
//  UBVisitorFeedViewController.m
//  
//
//  Created by Ricardo Nazario on 11/29/16.
//
//

#import "UBVisitorFeedViewController.h"
#import "UBVisitorTableViewCell.h"

@import FirebaseDatabase;

@interface UBVisitorFeedViewController () <VisitorCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *statusRef;

@property (weak, nonatomic) IBOutlet UITableView *visitorsTable;
@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSString *communityId;
@property (strong, nonatomic) NSString *communityName;

@end

@implementation UBVisitorFeedViewController

-(void)getVisitorRequests {
    
    _ref = [[[FIRDatabase database] reference] child:@"visitors"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"community-id"] queryEqualToValue:_communityId];
    
    [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            
            if (![_feedArray containsObject:snapshot]) {
                
                if (![_feedArray count]) {
                    [_feedArray addObject:snapshot];
                    [_visitorsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
//                    [self hideViewAnimated:_noGuestsLabel hide:YES];
//                    [self hideViewAnimated:_feedTable hide:NO];
                } else {
                    [_feedArray addObject:snapshot];
                    [_visitorsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                }
            }
        }
    }
            withCancelBlock:^(NSError *error) {
                
                NSLog(@"ERROR: %@", error);
                
            }];
    
    [query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        
        NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
        
        for (FIRDataSnapshot *snap in _feedArray) {
            if ([snapshot.key isEqualToString:snap.key]) {
                [deleteArray addObject:[NSNumber numberWithInteger:[_feedArray indexOfObject:snap] ]];
            }
        }
        
        [_visitorsTable beginUpdates];
        for (NSNumber *num in deleteArray) {
            
            if ([_feedArray count] == 1) {
                [_feedArray removeObjectAtIndex:[num integerValue]];
                [_visitorsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
//                [self hideViewAnimated:_feedTable hide:YES];
//                              [self hideViewAnimated:_noGuestsLabel hide:NO];
            } else {
                [_feedArray removeObjectAtIndex:[num integerValue]];
                [_visitorsTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        [_visitorsTable endUpdates];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UBVisitorTableViewCell *cell = [_visitorsTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    FIRDataSnapshot *snap = _feedArray[indexPath.row];
    NSDictionary<NSString *, NSDictionary *> *visitorDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id", snap.value,@"values", nil];
    NSString *unit = [visitorDict valueForKeyPath:@"values.unit"];
    NSString *superUnit = [visitorDict valueForKeyPath:@"values.super-unit"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, superUnit];
    NSString *visitorName = [visitorDict valueForKeyPath:@"values.name"];
    
    NSLog(@"Address: %@", address);
    
    cell.nameLabel.text = visitorName;
    cell.addressLabel.text = address;
    cell.statusLabel.text = [visitorDict valueForKeyPath:@"values.status"];
    cell.visitorId = [visitorDict valueForKeyPath:@"id"];
    [self listenToStatus:cell];
    
    return cell;
}

-(void)confirmVisitor:(UBVisitorTableViewCell *)cell {
    [self confirmController:cell.nameLabel.text withId:cell.visitorId];
}

-(void)listenToStatus:(UBVisitorTableViewCell *)cell {
    
    NSString *statusRefString = [NSString stringWithFormat:@"visitors/%@/status", cell.visitorId];
    
    [_statusRef child:statusRefString];
    [_statusRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        
        NSString *keyPath = [NSString stringWithFormat:@"%@.status", cell.visitorId];
        NSString *status = [snapshot.value valueForKeyPath:keyPath];
        
        cell.statusLabel.text = status;
        
    } withCancelBlock:^(NSError *error) {
        if (error) {
            cell.statusLabel.text = @"There has been an error";
        }
    }];
    
}

-(void)confirmController:(NSString *)visitorName withId:(NSString *)visitorId {
    
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to confirm that %@ is through the gate?", visitorName];
    
    NSDictionary *statusDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Verified at gate",@"status", nil];
    
    UIAlertController *confirmView = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                         message:message
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Accept"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       [[[_statusRef child:@"visitors"] child:visitorId ] updateChildValues:statusDict];
                                                       [confirmView dismissViewControllerAnimated:YES
                                                                                      completion:nil];
                                                   }];
    
    
    UIAlertAction *wait = [UIAlertAction actionWithTitle:@"Wait"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                
                                                     [confirmView dismissViewControllerAnimated:YES
                                                                                    completion:nil];
                                                 }];
    
    [confirmView addAction:confirm];
    [confirmView addAction:wait];
    [self presentViewController:confirmView animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _communityId = [_secDict valueForKeyPath:@"values.community-id"];
    _communityName = [_secDict valueForKeyPath:@"values.community-name"];
    
    _statusRef = [[FIRDatabase database] reference];
    
    _feedArray = [[NSMutableArray alloc] init];
    NSLog(@"Community ID: %@", _communityId);
    [self getVisitorRequests];
    NSLog(@"Dict: %@", _secDict);
    _visitorsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ Security", _communityName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
