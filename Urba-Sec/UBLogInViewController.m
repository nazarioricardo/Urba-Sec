//
//  UBLogInViewController.m
//  Urba-Sec
//
//  Created by Ricardo Nazario on 11/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBLogInViewController.h"
#import "UBVisitorFeedViewController.h"
#import "Constants.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBLogInViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *adminEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) NSString *communityName;
@property (weak, nonatomic) NSString *communityId;
@property (weak, nonatomic) NSDictionary *result;

@end

@implementation UBLogInViewController

- (IBAction)logInPressed:(id)sender {
    [self logIn];
}

-(void)logIn {
    
    [[FIRAuth auth] signInWithEmail:@"dgsepulveda@gmail.com"
                           password:@"iamjach"
                         completion:^(FIRUser *user, NSError *error) {
        
        if (error) {
            NSLog(@"Error: %@", error.description);
        } else {
            
            _ref = [[FIRDatabase database] reference];
            _ref = [[_ref child:@"security"] child:user.uid];
            [_ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if ([snapshot exists]) {
                    
                    _result = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
                    
                    NSLog(@"DICT: %@", _result);
                    
                    NSLog(@"Admin log in was successful");
                    [self performSegueWithIdentifier:logInSegue sender:self];
                    
                } else {
                    
                    NSLog(@"Attempted to log in without proper admin credentials");
                    [[FIRAuth auth] signOut:nil];
                }
            }];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidDisappear:(BOOL)animated {
    [_ref removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:logInSegue]) {
        UINavigationController *nav = [segue destinationViewController];
        UBVisitorFeedViewController *vfvc = (UBVisitorFeedViewController *)[nav topViewController];
        [vfvc setCommunityDict:_result];
    }
}


@end
