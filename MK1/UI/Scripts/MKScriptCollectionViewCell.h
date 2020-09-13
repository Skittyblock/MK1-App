// MKScriptCollectionViewCell.h

#import <UIKit/UIKit.h>

@class MKScript;

@interface MKScriptCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MKScript *script;
@property (nonatomic, strong) UIVisualEffectView *cardView;
@property (nonatomic, strong) UIImageView *cardImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end

