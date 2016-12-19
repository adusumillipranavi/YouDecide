//
//  MPKItemCollectionViewCell.m
//  Pods
//
//  Created by Daniel Loomb on 1/22/15.
//
//

#import "MPKAssetCell.h"

#import <MEAPhotoKit.h>

@implementation MPKAssetCell

-(void)awakeFromNib
{
	if (self.cellSelectionIndicatorImageView.image == nil)
	{
		[self.cellSelectionIndicatorImageView setImage:[MEAPhotoKit imageNamed:@"magenta_tick.png" fromBundle:@"mea-photokit-UserInterface"]];
	}
}

-(void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	
	self.cellSelectionIndicatorImageView.hidden = !selected;
}

@end
