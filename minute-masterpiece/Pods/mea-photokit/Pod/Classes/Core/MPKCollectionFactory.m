//
//  MPKCollectionFactory.m
//  Pods
//
//  Created by Daniel on 27/10/15.
//
//

#import "MPKCore.h"



@implementation MPKCollectionFactory

NSString* ClassNameFromMPKCollectionType(MPKCollectionType type)
{
	switch (type) {
		case MPKCollectionTypeLocal:
			return @"MPKLocalCollection";
		case MPKCollectionTypeInstagram:
			return @"MPKInstagramCollection";
		case MPKCollectionTypeFacebook:
			return @"MPKFacebookCollection";
		case MPKCollectionTypeDropbox:
			return @"MPKDropboxCollection";
		case MPKCollectionTypeFlickr:
			return @"MPKFlickrCollection";
		case MPKCollectionTypeGoogle:
			return @"MPKGoogleCollection";
		case MPKCollectionTypeTwitter:
			return @"MPKTwitterCollection";
		case MPKCollectionTypeDeviantArt:
			return @"MPKDeviantArtCollection";
		case MPKCollectionTypePinterest:
			return @"MPKPinterestCollection";
		case MPKCollectionTypeLive:
			return @"MPKLiveCollection";
		case MPKCollectionTypeVideo:
			return @"MPKVideoCollection";
		case MPKCollectionTypeAmazon:
			return @"MPKAmazonCollection";
        case MPKCollectionTypeEmoji:
            return @"MPKEmojiCollection";
        case MPKCollectionTypeInstagramPublic:
            return @"MPKInstagramPublicCollection";
		case MPKCollectionTypeSanDisk:
			return @"MPKSanDiskCollection";
	}
	return @"";
}


+(MPKCollection *)createCollectionGivenTypes:(MPKCollectionType)types
{
	MPKCollection *base = [[MPKCollection alloc] init];
	
	int count = sizeof(MPKCollectionType) * 8;
	for (NSUInteger i = 1; i < count; i++)
	{
		MPKCollectionType type = (MPKCollectionType)(1 << i);
		NSString *classname = ClassNameFromMPKCollectionType(type);
		if (!classname.length) {
			break;
		}
		
		if ((types & type) != 0) {
			
			id collection = [[NSClassFromString(classname) alloc] initRootCollection];

			if (collection == nil) {
				[[NSException exceptionWithName:@"NilCollectionException" reason:@"A MPKCollection class failed to initialize. Did you forget to add a Subpod?" userInfo:@{}] raise];
			}
			
			[base addMPKCollection:collection];
		}
	}


	return base;
}

@end
