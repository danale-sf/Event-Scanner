//
//  ScanViewController.m
//  SimpleScan
//
//  Created by Michael Critz on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScanViewController.h"



@interface ScanViewController ()
@end

@implementation ScanViewController

@synthesize readerView, resultText, cameraSim, sfdcArray, scannedText, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Scan";
    readerView.readerDelegate = self;
    
    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        cameraSim = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        cameraSim.readerView = readerView;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [cameraSim release];
    cameraSim = nil;
    readerView.readerDelegate = nil;
    [readerView release];
    readerView = nil;
    [resultText release];
    resultText = nil;
    [self setScannedText:nil];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) viewDidAppear: (BOOL) animated
{
    // run the reader when the view is visible
    [readerView start];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [readerView stop];
}


- (void) readerView: (ZBarReaderView*) view
     didReadSymbols: (ZBarSymbolSet*) syms
          fromImage: (UIImage*) img
{
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        
        scannedText = [[NSString alloc] initWithFormat:@"%@",sym.data];
        NSLog(@"My scan results: %@",scannedText);

        resultText.text = scannedText;

        // Here we use a query that should work on either Force.com or Database.com
        // NSString *myScanText = [[NSString alloc] initWithFormat:scannedText];
        
        NSString *scanQuery = [NSString stringWithFormat:@"Select id, Status__c, Contact__r.Email, Contact__r.FirstName, Contact__r.LastName, Contact__c From Presence__c WHERE ID = '%@'",scannedText];
        SFRestRequest *request = [[SFRestAPI sharedInstance] requestForQuery:scanQuery];
        [[SFRestAPI sharedInstance] send:request delegate:self];
        
        /*
        // modify object
        NSDictionary *updatedFields = [NSDictionary dictionaryWithObjectsAndKeys:
                                       updatedLastName, @"LastName", 
                                       nil];
        request = [[SFRestAPI sharedInstance] requestForUpdateWithObjectType:@"Contact" objectId:contactId fields:updatedFields];
        [self sendSyncRequest:request];
        STAssertEqualObjects(_requestListener.returnStatus, kTestRequestStatusDidLoad, @"request failed"); 
        
        We would replace the requestForUpdateWithObjectType:@"Contact" with:
        requestForUpdateWithObjectType:@"Presence__c"
         */
        break;
    }
}

- (IBAction)cancelButtonPressed {
    NSLog(@"Cancel button pressed.");
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSLog(@"jsonResponse: %@",jsonResponse);
    
    sfdcArray = [jsonResponse objectForKey:@"records"];
    NSLog(@"request:didLoadResponse: # of records: %d", sfdcArray.count);
    if (sfdcArray.count < 1) {
        [self alertOnFailedRequest];
    }
    // NSLog(@"Response from SFDC: %@",sfdcArray);
    
    
    // send data to delegate
    if([delegate respondsToSelector:@selector(parseContactData:)])
    {
        //send the delegate function with the returned array
        [delegate setpresenceID:scannedText];
        [delegate parseContactData:sfdcArray];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{}];
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
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"I didn't understand that code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [alert show];
}


@end
