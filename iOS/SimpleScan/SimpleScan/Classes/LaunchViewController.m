//
//  LaunchViewController.m
//  SimpleScan
//
//  Created by Michael Critz on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LaunchViewController.h"
#import "ScanViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

@synthesize contactInfo;
@synthesize nameLabel;
@synthesize emailLabel;
@synthesize checkinButton;
@synthesize scanButton;
// @synthesize presenceID;
@synthesize presenceToUpdate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Simple Scan";
    checkinButton.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setEmailLabel:nil];
    [self setCheckinButton:nil];
    [self setScanButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Scan Action
- (void)scanButtonPressed:(id)sender {
    NSLog(@"Scan Button Pressed");
    ScanViewController *scanView = [[ScanViewController alloc] init];
    scanView.delegate = self;
    [self presentViewController:scanView animated:YES completion:^{}];
}

#pragma mark - Deal with Results
-(void)parseContactData:(NSArray *)returnedArray {
    checkinButton.hidden = NO;

    // NSLog(@"parseContactData called. returnedArray: \n %@",returnedArray);
    for (NSDictionary *obj in returnedArray) {
        NSLog(@"presenceID: %@",presenceID);
        // NSLog(@"obj: %@",obj);
        contactInfo = [[NSDictionary alloc] initWithDictionary:[obj objectForKey:@"Contact__r"]];
        NSLog(@"contactInfo: %@",contactInfo);
                
        nameLabel.text = [[[NSString alloc] initWithFormat:@"%@ %@",[contactInfo objectForKey:@"FirstName"],[contactInfo objectForKey:@"LastName"],nil] autorelease];
        emailLabel.text = [contactInfo objectForKey:@"Email"];
        
    }
    // nameLabel.text = [[returnedArray objectForKey:@"Property__r"] objectForKey:@"Name"];
}
-(void)setpresenceID:(NSString *)returnedPresenceID{
    presenceToUpdate = returnedPresenceID;
}
- (void)dealloc {
    [nameLabel release];
    [emailLabel release];
    [checkinButton release];
    [scanButton release];
    [contactInfo release];
    [super dealloc];
}
- (IBAction)checkinButtonPressed:(UIButton *)sender {

    NSLog(@"checkinButtonPressed");
     
     // tell sfdc to change status to "Attended"
     NSDictionary *updatedFields = [NSDictionary dictionaryWithObjectsAndKeys:@"Attended", @"Status__c", nil];
    SFRestRequest *request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Presence__c" objectId:presenceToUpdate fields:updatedFields];
    [[SFRestAPI sharedInstance] send:request delegate:self];
    // requestForUpdateWithObjectType does not return a json.
    
    // second request to confirm change in status
    NSString *confirmationQuery = [NSString stringWithFormat:@"Select id, Status__c  From Presence__c WHERE ID = '%@'",presenceToUpdate];
    SFRestRequest *requestToConfirmUpdate = [[SFRestAPI sharedInstance] requestForQuery:confirmationQuery];
    [[SFRestAPI sharedInstance] send:requestToConfirmUpdate delegate:self];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSLog(@"requestToConfirmUpdate: %@",jsonResponse);

    NSArray *sfdcResponse = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: # of records: %d", sfdcResponse.count);
    for (NSDictionary *obj in sfdcResponse) {
        NSLog(@"obj: %@",obj);
        NSString *presenseStatus = [[[NSString alloc] initWithFormat:@"%@",[obj objectForKey:@"Status__c"]] autorelease];
        if ([presenseStatus isEqualToString:@"Attended"]) {
            NSLog(@"presenseStatus == Attended");
            [self sucessfulConfirmation];
        } else {
            NSLog(@"presenseStatus != 'Attended' actual value: %@",presenseStatus);
            [self sucessfulConfirmation];
        }
    }
}


#pragma mark - SFDC SDK Error Handling

- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    [self alertOnFailedRequest];
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    [self alertOnFailedRequest];
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    [self alertOnFailedRequest];
}

- (void)alertOnFailedRequest {
    checkinButton.hidden = YES;

    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"I didn't understand that code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)failConfirmation {
    checkinButton.hidden = NO;
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"So Sorry!" message:@"I wasn't able to confirm this invite. Try again in a minute." delegate:self cancelButtonTitle:@"D’oh!" otherButtonTitles:nil] autorelease];
    [alert show];
}

- (void)sucessfulConfirmation {
    checkinButton.hidden = YES;

    NSString *sucessMessage = [NSString stringWithFormat:@"%@ is checked in.",[contactInfo objectForKey:@"FirstName"]];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Sucess!" message:sucessMessage delegate:self cancelButtonTitle:@"Thank You" otherButtonTitles: nil] autorelease];
    [alert show];
    
    nameLabel.text = @"Scan to Check-In";
    emailLabel.text = @"";
}

@end
