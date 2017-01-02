//
//  SettingsViewController.m
//  Urba-Sec
//
//  Created by Ricardo Nazario on 1/2/17.
//  Copyright © 2017 Ricardo Nazario. All rights reserved.
//

#import "SettingsViewController.h"
#import "UBLogInViewController.h"

@import FirebaseAuth;

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (IBAction)signOutPressed:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"currentSec"];
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Sign out error: %@", signOutError);
        return;
    }
    
    // After sign out, go to log in screen
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UBLogInViewController *uwvc = [storyboard instantiateViewControllerWithIdentifier:@"LogIn"];
    [self presentViewController:uwvc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Settings";
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
