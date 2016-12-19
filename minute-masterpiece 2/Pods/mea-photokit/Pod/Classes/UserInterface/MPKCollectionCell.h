//
//  MPKCollectionCell.h
//  Pods
//
//  Created by Daniel Loomb on 2/6/15.
//
//

#import <UIKit/UIKit.h>

@interface MPKCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelMain;
@property (weak, nonatomic) IBOutlet UILabel *labelSecondary;

@end
