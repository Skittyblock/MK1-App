// MKScriptCollectionViewCell.m

#import "MKScriptCollectionViewCell.h"
#import "MKScript.h"

@implementation MKScriptCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Card view
        /*self.cardView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        self.cardView.layer.cornerRadius = 6;
        self.cardView.clipsToBounds = YES;
        self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.cardView];*/

        self.cardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderImage"]];
        //self.cardImageView.frame = self.cardView.frame;
        self.cardImageView.layer.cornerRadius = 6;
        self.cardImageView.clipsToBounds = YES;
        self.cardImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.cardImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.cardImageView];
        
        [self.cardImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
        [self.cardImageView.heightAnchor constraintEqualToAnchor:self.widthAnchor multiplier:(97 / 163.5)].active = YES;
        [self.cardImageView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [self.cardImageView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        
        // Title label
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.titleLabel];
        
        [self.titleLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-8].active = YES;
        [self.titleLabel.heightAnchor constraintEqualToConstant:18].active = YES;
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.cardImageView.bottomAnchor constant:8].active = YES;
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4].active = YES;
        
        // Subtitle label
        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        self.subtitleLabel.font = [UIFont systemFontOfSize:14];
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.subtitleLabel];
        
        [self.subtitleLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-8].active = YES;
        [self.subtitleLabel.heightAnchor constraintEqualToConstant:16].active = YES;
        [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.cardImageView.bottomAnchor constant:8 + 18].active = YES;
        [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:4].active = YES;

        [self updateColors];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    /*if (self.script) {
        CAShapeLayer *maskLayer = [CAShapeLayer new];
        if ([self.script.shape isEqualToString:@"circle"]) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.cardView.bounds.size.width, self.cardView.bounds.size.height)];
            [path addArcWithCenter:CGPointMake(path.bounds.size.width/2, path.bounds.size.height/2) radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
            maskLayer.path = path.CGPath;
        } else if ([self.script.shape isEqualToString:@"square"]) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.cardView.bounds.size.width, self.cardView.bounds.size.height)];
            [path moveToPoint:CGPointMake(self.cardView.bounds.size.width/2-10, self.cardView.bounds.size.height/2-10)];
            [path addLineToPoint:CGPointMake(self.cardView.bounds.size.width/2+10, self.cardView.bounds.size.height/2-10)];
            [path addLineToPoint:CGPointMake(self.cardView.bounds.size.width/2+10, self.cardView.bounds.size.height/2+10)];
            [path addLineToPoint:CGPointMake(self.cardView.bounds.size.width/2-10, self.cardView.bounds.size.height/2+10)];
            [path closePath];
            maskLayer.path = path.CGPath;
        } else if ([self.script.shape isEqualToString:@"triangle"]) {
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.cardView.bounds.size.width, self.cardView.bounds.size.height)];
            [path moveToPoint:CGPointMake(self.cardView.bounds.size.width/2, self.cardView.bounds.size.height/2-10)];
            [path addLineToPoint:CGPointMake(self.cardView.bounds.size.width/2+12, self.cardView.bounds.size.height/2+10)];
            [path addLineToPoint:CGPointMake(self.cardView.bounds.size.width/2-12, self.cardView.bounds.size.height/2+10)];
            [path closePath];
            maskLayer.path = [path bezierPathByReversingPath].CGPath;
        }
        maskLayer.fillRule = kCAFillRuleEvenOdd;
        self.cardView.layer.mask = maskLayer;
    }*/
}

- (void)setScript:(MKScript *)script {
    _script = script;
    
    self.titleLabel.text = script.name;
    self.subtitleLabel.text = script.author ?: @"Unknown";
    self.cardImageView.image = script.image ?: [UIImage imageNamed:@"placeholderImage"];
    
    /*if (script.image) {
        self.cardImageView.hidden = NO;
        self.cardView.hidden = YES;
    } else {
        if (self.cardImageView) self.cardImageView.hidden = YES;
        self.cardView.hidden = NO;
    }*/
    
    [self setNeedsLayout];
}

- (void)updateColors {
    if (@available(iOS 13.0, *)) {
        self.titleLabel.textColor = [UIColor labelColor];
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            self.cardView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        } else {
            self.cardView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.subtitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        }
    } else {
        self.cardView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.titleLabel.textColor = [UIColor blackColor];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateColors];
}

@end
