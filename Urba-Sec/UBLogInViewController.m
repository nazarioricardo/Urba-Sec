//
//  UBLogInViewController.m
//  Urba-Sec
//
//  Created by Ricardo Nazario on 11/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBLogInViewController.h"
#import "UBVisitorFeedViewController.h"
#import "UBFIRDatabaseManager.h"
#import "Constants.h"

@import Firebase;

@interface UBLogInViewController ()

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
            
            FIRDatabaseReference *ref = [[FIRDatabase database] reference];
            ref = [[ref child:@"security"] child:user.uid];
            [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                if ([snapshot exists]) {
                    
                    _result = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
                    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:logInSegue]) {
        UITabBarController *tbc = [segue destinationViewController];
        UBVisitorFeedViewController *vfvc = [tbc.viewControllers objectAtIndex:0];
        [vfvc setCommunityDict:_result];
    }
}


@end
