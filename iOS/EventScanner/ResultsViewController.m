//
//  SecondViewController.m
//  TabReader
//
//  
//

#import "ResultsViewController.h"
#import "constants.h"

@implementation ResultsViewController
@synthesize resultWebView;
@synthesize userHasScanned;
@synthesize resultText;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"userHasScanned: %@",userHasScanned);
    
    if (!userHasScanned) {
        self.resultText.text = @"New Registration";
            
        NSURL *myURL = [NSURL URLWithString:[kREG_URL stringByAppendingString:@"&source=n1nj4d0j0"]];
                
        [self.resultWebView loadRequest:[NSURLRequest requestWithURL:myURL]];       
    }

}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orient
{
    return(YES);
}
- (void)dealloc {
    // [userHasScanned release];
    [resultWebView release];
    [super dealloc];
}
- (void)viewDidUnload {
    // [self userHasScanned:nil];
    [self setResultWebView:nil];
    [super viewDidUnload];
}
/* 
-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability *reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Notification: Reachable");
    }
    else
    {
        NSLog(@"Notification: Unreachable");
        if (!alertIsActive) {
            alertIsActive = YES;
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Internet Error"
                                  message:@"Check-in site unreachable. Please check network connection."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}
*/ 

@end
