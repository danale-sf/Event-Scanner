//
//  LaunchViewController.h
//  SimpleScan
//
//  Created by Michael Critz on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanViewController.h"
#import "SFRestAPI.h"

@interface LaunchViewController : UIViewController <scanViewDataSource,SFRestDelegate>
{
    NSString *presenceID;
    NSArray *contactArray;
}

@property (nonatomic, retain) NSDictionary *contactInfo;
@property (nonatomic, retain) NSString *presenceToUpdate;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *emailLabel;
@property (retain, nonatomic) IBOutlet UIButton *checkinButton;
- (IBAction)checkinButtonPressed:(UIButton *)sender;
@property (nonatomic, retain) IBOutlet UIButton *scanButton;
-(IBAction)scanButtonPressed:(id)sender;
- (void)alertOnFailedRequest;
- (void)sucessfulConfirmation;
- (void)failConfirmation;

@end
