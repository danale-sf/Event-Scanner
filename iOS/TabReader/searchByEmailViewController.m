//
//  searchByEmailViewController.m
//  TabReader
//
//  Created by Michael Critz on 6/20/12.
//

#import "searchByEmailViewController.h"
#import "constants.h"

@implementation searchByEmailViewController
@synthesize searchEmailWebView = _searchEmailWebView;
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
    // Do any additional setup after loading the view from its nib.    
    
    NSURL *defaultURL = [NSURL URLWithString:[kREG_URL stringByAppendingString:@"&source=n1nj4d0j0"]];
    
    [self.searchEmailWebView loadRequest:[NSURLRequest requestWithURL:defaultURL]];
    // [defaultURL release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.searchEmailWebView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

- (void)dealloc {
    [_searchEmailWebView release];
    [super dealloc];
}


@end
