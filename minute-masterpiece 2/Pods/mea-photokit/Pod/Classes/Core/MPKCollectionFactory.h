//
//  MPKCollectionFactory.h
//  Pods
//
//  Created by Daniel on 27/10/15.
//
//

#import "MPKCore.h"

@class MPKCollection;

@interface MPKCollectionFactory : NSObject

+(MPKCollection *)createCollectionGivenTypes:(MPKCollectionType)types;

@end
