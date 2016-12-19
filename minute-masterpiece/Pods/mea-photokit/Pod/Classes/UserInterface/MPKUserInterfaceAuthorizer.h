//
//  MPKUserInterfaceAuthorizer.h
//  Pods
//
//  Created by Daniel on 20/11/15.
//
//

#import "MEAPhotoKit.h"
#import "MPKCore.h"

@interface MPKUserInterfaceAuthorizer : NSObject <MPKAuthorizationProtocol>

+ (MPKUserInterfaceAuthorizer *)defaultAuthorizer;

@end
