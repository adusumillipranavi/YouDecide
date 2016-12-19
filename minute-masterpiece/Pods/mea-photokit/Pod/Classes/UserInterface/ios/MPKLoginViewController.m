//
//  MPKLoginViewController.m
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import "MPKLoginViewController.h"
#import "MPKUserInterface.h"

@interface MPKLoginViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, copy) void (^completionHandler)(NSError *error, NSURL *param);

@end

@implementation MPKLoginViewController

- (UIActivityIndicatorView *)activityIndicator{
    if (!_activityIndicator) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:activityIndicator];
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = YES;
        _activityIndicator = activityIndicator;
    }
    return _activityIndicator;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)dealloc
{
	NSLog(@"LoginView Controller Dealloc");
	[self.webView loadHTMLString:@"" baseURL:nil];
	@autoreleasepool
	{
		self.webView = nil;
	}
	self.completionHandler = nil;
}

-(void)didFinishLoadingWithError:(NSError *)error andUrl:(NSURL *)url {
    [self.activityIndicator stopAnimating];
	[[MPKUserInterface sharedInstance] setBlockingActivityIndicatorVisible:NO];
    
    if(error){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
	if (self.completionHandler) {
		self.completionHandler(error, url);
	}
}

-(void)loadUrl:(NSURL *)url completionHandler:(void(^)(NSError *error, NSURL *url))completionHandler
{
	[[MPKUserInterface sharedInstance] setBlockingActivityIndicatorVisible:YES];
	
	self.completionHandler = completionHandler;
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:urlRequest];
    
    [self.activityIndicator startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self didFinishLoadingWithError:nil andUrl:webView.request.URL];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[self didFinishLoadingWithError:error andUrl:webView.request.URL];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
	NSLog(@"start, %@", webView.request.URL);
}


#pragma mark - Actions


- (IBAction)cancelTouchUpInside:(id)sender
{
	[self.webView loadHTMLString:@"" baseURL:nil];
	[self.webView reload];
	
	NSError *error = [[NSError alloc] initWithDomain:@"com.meamobile.photokit.errors" code:401 userInfo:@{NSLocalizedFailureReasonErrorKey : @"User cancelled"}];
	[self didFinishLoadingWithError:error andUrl:nil];
	
	self.completionHandler = nil;
	self.webView.delegate = nil;
	self.webView = nil;
}

@end
