//
//  MPKLocalCachingModule.m
//  Pods
//
//  Created by Daniel Loomb on 2/10/15.
//
//

#import "MPKLocalCachingModule.h"

#import "MEAPhotoKit.h"
#import "MPKLocal.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MPKLocalCachingModule()

@property (nonatomic, strong) PHCachingImageManager *phCachingImageManager;

@end

@implementation MPKLocalCachingModule

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		self.phCachingImageManager = [[PHCachingImageManager alloc] init];
	}
	return self;
}

-(void)requestThumbnailForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
	MPKLocalAsset *localAsset = (id)asset;
	
	if (localAsset.alAsset)
	{
		resultHandler([UIImage imageWithCGImage:[localAsset.alAsset aspectRatioThumbnail]]);
	}
	else
	{
		[self.phCachingImageManager requestImageForAsset:localAsset.phAsset
											  targetSize:CGSizeMake(160, 160)
											 contentMode:PHImageContentModeAspectFill
												 options:nil
										   resultHandler:^(UIImage *result, NSDictionary *info) {
											   resultHandler(result);
										   }];
	}

}

-(void)requestFullImageForAsset:(MPKAsset *)asset resultHandler:(void (^)(UIImage *))resultHandler
{
	MPKLocalAsset *localAsset = (id)asset;
	
	if (localAsset.alAsset)
	{
		ALAssetRepresentation *rep = localAsset.alAsset.defaultRepresentation;
		
		NSString *xmpString = rep.metadata[@"AdjustmentXMP"];
		if(xmpString)
		{
//			NSData *xmpData = [xmpString dataUsingEncoding:NSUTF8StringEncoding];
//			
//			CIImage *image = [CIImage imageWithCGImage:rep.fullResolutionImage];
//			
//			NSError *error = nil;
//			NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
//														 inputImageExtent:image.extent
//																	error:&error];
//			
//			if (error)
//			{
//				NSLog(@"ERROR:: Error during CIFilter creation: %@", [error localizedDescription]);
//			}
//			
//			for (CIFilter *filter in filterArray) {
//				[filter setValue:image forKey:kCIInputImageKey];
//				image = [filter outputImage];
//			}
//			
//			CIContext* context = [CIContext contextWithOptions:nil];
//			CGImageRef cgImage = [context createCGImage:image fromRect:[image extent]];
//			context = nil;
//			image = nil;
//			
//			oimage = [UIImage imageWithCGImage:cgImage];
//			
//			CGImageRelease(cgImage);
//			resultHandler(oimage);
			resultHandler([UIImage imageWithCGImage:[rep fullScreenImage]]);

		}
		else
		{
			resultHandler([UIImage imageWithCGImage:[rep fullResolutionImage]]);
		}
	}
	else
	{
		@autoreleasepool {
			[self.phCachingImageManager requestImageDataForAsset:localAsset.phAsset
														 options:nil
												   resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
													   
													   if (imageData != nil)
													   {
														   resultHandler([UIImage imageWithData:imageData]);
													   }
													   else
													   {
														   resultHandler(nil);
													   }
													   
												   }];
		}
	}
}


-(void)requestBytesizeForAsset:(MPKAsset *)asset resultHandler:(void (^)(int64_t))resultHandler
{
	MPKLocalAsset *localAsset = (id)asset;
	
	if (localAsset.alAsset)
	{
		resultHandler(localAsset.alAsset.defaultRepresentation.size);
	}
	else
	{
		PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
		options.networkAccessAllowed = YES;
		options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
		options.synchronous = YES;
		
		[[PHCachingImageManager defaultManager] requestImageDataForAsset:localAsset.phAsset
																 options:options
														   resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {

															   if (imageData.length == 0 || [info[PHImageResultIsDegradedKey] boolValue]) {
																   NSLog(@"");
																   return;
															   }
															   
															   resultHandler(imageData.length);
														   }];
	}
}

@end
