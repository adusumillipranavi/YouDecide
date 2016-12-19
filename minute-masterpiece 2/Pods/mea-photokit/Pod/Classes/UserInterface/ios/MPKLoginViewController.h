//
//  MPKLoginViewController.h
//  mea-photokit
//
//  Created by Daniel Loomb on 10/7/14.
//  Copyright (c) 2014 MEA Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPKLoginViewController : UIViewController

-(void)loadUrl:(NSURL*)url completionHandler:(void(^)(NSError *error, NSURL *url))completionHandler;

@end
