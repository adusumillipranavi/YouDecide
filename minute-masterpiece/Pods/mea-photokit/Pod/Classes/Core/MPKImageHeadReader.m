//
//  MPKImageHeadReader.m
//  Pods
//
//  Created by Daniel Loomb on 11/7/16.
//
//

#import "MPKImageHeadReader.h"

@interface MPKImageHeadReader()

@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (nonatomic, copy) void (^onReadComplete)(uint32_t width, uint32_t height, NSString *type);

@end

@implementation MPKImageHeadReader

- (void)read:(NSData *)data withCompletion:(void (^)(uint32_t, uint32_t, NSString *))completion {
	self.onReadComplete = completion;
	self.fileType = nil;
	self.receivedData = [NSMutableData dataWithData:data];
	
	//Parse metadata
	const unsigned char* cString = [self.receivedData bytes];
	const NSInteger length = [self.receivedData length];
	const char pngSignature[8] = {137, 80, 78, 71, 13, 10, 26, 10};
	const char bmpSignature[2] = {66, 77};
	const char gifSignature[2] = {71, 73};
	const char jpgSignature[2] = {255, 216};
	
	if(!self.fileType )
	{
		if( memcmp(pngSignature, cString, 8) == 0 )
		{
			self.fileType = @"PNG";
		}
		else if( memcmp(bmpSignature, cString, 2) == 0 )
		{
			self.fileType = @"BMP";
		}
		else if( memcmp(jpgSignature, cString, 2) == 0 )
		{
			self.fileType = @"JPG";
		}
		else if( memcmp(gifSignature, cString, 2) == 0 )
		{
			self.fileType = @"GIF";
		}
	}
	
	if( [self.fileType isEqualToString: @"PNG"] )
	{
		[self pngOfLength:length withCString:cString];
	}
	else if( [self.fileType isEqualToString: @"BMP"] )
	{
		[self bmpOfLength:length withCString:cString];
	}
	else if( [self.fileType isEqualToString: @"JPG"] )
	{
		[self jpgOfLength:length withCString:cString];
	}
	else if( [self.fileType isEqualToString: @"GIF"] )
	{
		[self gifOfLength:length withCString:cString];
	}
}

-(void)pngOfLength:(NSUInteger)length withCString:(const unsigned char*)cString
{
	char type[5];
	int offset = 8;
	
	uint32_t chunkSize = 0;
	int chunkSizeSize = sizeof(chunkSize);
	
	if( offset+chunkSizeSize > length )
		return;
	
	memcpy(&chunkSize, cString+offset, chunkSizeSize);
	chunkSize = OSSwapInt32(chunkSize);
	offset += chunkSizeSize;
	
	if( offset + chunkSize > length )
		return;
	
	memcpy(&type, cString+offset, 4); type[4]='\0';
	offset += 4;
	
	if( strcmp(type, "IHDR") == 0 ) {   //Should always be first
		uint32_t width = 0, height = 0;
		memcpy(&width, cString+offset, 4);
		offset += 4;
		width = OSSwapInt32(width);
		
		memcpy(&height, cString+offset, 4);
		offset += 4;
		height = OSSwapInt32(height);
		
#ifdef DEBUG
		NSLog(@"PNG: %ld x %ld", width, height);
#endif
		
		self.onReadComplete(width, height, @"PNG");
	}
	
}


-(void)bmpOfLength:(NSUInteger)length withCString:(const unsigned char*)cString
{
	int offset = 18;
	uint32_t width = 0, height = 0;
	memcpy(&width, cString+offset, 4);
	offset += 4;
	
	memcpy(&height, cString+offset, 4);
	offset += 4;
	
#ifdef DEBUG
	NSLog(@"BMP: %ld x %ld", width, height);
#endif
	
	self.onReadComplete(width, height, @"BMP");
}


-(void)jpgOfLength:(NSUInteger)length withCString:(const unsigned char*)cString
{
	int offset = 4;
	uint32_t block_length = cString[offset]*256 + cString[offset+1];
	
	while (offset<length)
	{
		offset += block_length;
		
		if( offset >= length ) { break; }
		
		if( cString[offset] != 0xFF ) { break; }
		
		if( cString[offset+1] == 0xC0 ||
		   cString[offset+1] == 0xC1 ||
		   cString[offset+1] == 0xC2 ||
		   cString[offset+1] == 0xC3 ||
		   cString[offset+1] == 0xC5 ||
		   cString[offset+1] == 0xC6 ||
		   cString[offset+1] == 0xC7 ||
		   cString[offset+1] == 0xC9 ||
		   cString[offset+1] == 0xCA ||
		   cString[offset+1] == 0xCB ||
		   cString[offset+1] == 0xCD ||
		   cString[offset+1] == 0xCE ||
		   cString[offset+1] == 0xCF )
		{
			
			uint32_t width = 0, height = 0;
			
			height = cString[offset+5]*256 + cString[offset+6];
			width = cString[offset+7]*256 + cString[offset+8];

#ifdef DEBUG
			NSLog(@"JPG: %ld x %ld", width, height);
#endif
			
			self.onReadComplete(width, height, @"JPG");
		}
		else {
			offset += 2;
			block_length = cString[offset]*256 + cString[offset+1];
		}
		
	}
}


-(void)gifOfLength:(NSUInteger)length withCString:(const unsigned char*)cString
{
	int offset = 6;
	uint32_t width = 0, height = 0;
	memcpy(&width, cString+offset, 2);
	offset += 2;
	
	memcpy(&height, cString+offset, 2);
	offset += 2;
	
#ifdef DEBUG
	NSLog(@"GIF: %ld x %ld", width, height);
#endif
	
	self.onReadComplete(width, height, @"GIF");
}


@end
