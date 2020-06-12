// MKEditableTableViewCell.m

#import "MKEditableTableViewCell.h"

@implementation MKEditableTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.textField = [[UITextField alloc] init];
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.textField];
        
        CGFloat x = 15*2 + self.textLabel.bounds.size.width;
        [self.textField.widthAnchor constraintEqualToAnchor:self.widthAnchor constant:-(x+15)].active = YES;
        [self.textField.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-24].active = YES;
        [self.textField.topAnchor constraintEqualToAnchor:self.topAnchor constant:12].active = YES;
        [self.textField.leadingAnchor constraintEqualToAnchor:self.textLabel.trailingAnchor constant:12].active = YES;
    }
    
    return self;
}

@end
