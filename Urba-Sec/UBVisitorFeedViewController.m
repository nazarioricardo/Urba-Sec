//
//  UBVisitorFeedViewController.m
//  
//
//  Created by Ricardo Nazario on 11/29/16.
//
//

#import "UBVisitorFeedViewController.h"
#import "UBFIRDatabaseManager.h"

@interface UBVisitorFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *visitorsTable;
@property (strong, nonatomic) NSMutableArray *visitorsArray;
@property (strong, nonatomic) NSString *communityId;

@end

@implementation UBVisitorFeedViewController

-(void)getVisitorRequests {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"visitors"
                                     orderedBy:@"community-id"
                                    filteredBy:_communityId
                            withSuccessHandler:^(NSArray *results) {
                                
                                _visitorsArray = [NSMutableArray arrayWithArray:results];
                                NSLog(@"Array: %@", _visitorsArray);
                                [_visitorsTable reloadData];
                            }
                                orErrorHandler:^(NSError *error) {
                                    NSLog(@"Error: %@", error.description);
                                }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_visitorsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_visitorsTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary<NSString *, NSDictionary *> *visitorDict = _visitorsArray[indexPath.row];
    NSString *unit = [visitorDict valueForKeyPath:@"values.unit"];
    NSString *superUnit = [visitorDict valueForKeyPath:@"values.super-unit"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, superUnit];
    NSString *visitorName = [visitorDict valueForKeyPath:@"values.name"];
    
    NSLog(@"Address: %@", address);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", visitorName, address];
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _communityId = [_communityDict valueForKeyPath:@"values.community-id"];
    
    NSLog(@"Community ID: %@", _communityId);
    [self getVisitorRequests];
    NSLog(@"Dict: %@", _communityDict);
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
