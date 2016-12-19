//
//  MPKUserInterfaceAuthorizer.m
//  Pods
//
//  Created by Daniel on 20/11/15.
//
//

#import "MPKUserInterfaceAuthorizer.h"
#import "MPKUserInterface.h"

@implementation MPKUserInterfaceAuthorizer

+ (MPKUserInterfaceAuthorizer *)defaultAuthorizer
{
	static MPKUserInterfaceAuthorizer *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}





@end
