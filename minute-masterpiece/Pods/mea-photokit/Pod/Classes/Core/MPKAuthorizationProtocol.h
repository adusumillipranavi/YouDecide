//
//  MPKAuthorizationProtocol.h
//  Pods
//
//  Created by Daniel on 20/11/15.
//
//

#import <Foundation/Foundation.h>

@class MPKSourceSession;

@protocol MPKAuthorizationProtocol <NSObject>

-(void)authorizeSource:(MPKSourceSession *)source withUrl:(NSURL *)url andCompletion:(void (^)(NSError *, id))completion;

@end
