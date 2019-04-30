#import "MISBadgeBarButtonItem.h"

@interface MISBadgeBarButtonItem()
@property (nonatomic, retain) UILabel *badgeLabel;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, retain) UIView *holdView;
@property (nonatomic, retain) UIButton *button;
@end

@implementation MISBadgeBarButtonItem
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action{
    self.badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(52, 4, 16, 16)];
    self.badgeLabel.backgroundColor = [UIColor colorWithRed:1 green:0.231 blue:0.188 alpha:1];
    self.badgeLabel.font = [UIFont systemFontOfSize:10];
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.layer.cornerRadius = 8.0;
    self.badgeLabel.layer.masksToBounds = true;
    self.badgeLabel.text = @"10";
    
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = CGRectMake(0, 0, 60, 44);
    self.button.titleLabel.font = [UIFont systemFontOfSize:17];
    self.button.backgroundColor = [UIColor clearColor];
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:title forState:UIControlStateNormal];
    
    self.holdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [self.holdView addSubview:self.button];
    [self.holdView addSubview:self.badgeLabel];
    
    self = [super initWithCustomView:self.holdView];
    if(self){
        self.style = style;
        self.target = target;
        self.action = action;
    }
    return self;
}

-(void) setBadgeValue:(NSString *)string{
    _badgeValue = string;
    self.badgeLabel.text = string;
    if(string){
        self.badgeLabel.hidden = NO;
        self.button.frame = CGRectMake(0, 0, 60, 44);
    } else {
        self.badgeLabel.hidden = YES;
        self.button.frame = CGRectMake(12, 0, 60, 44);
    }
}
@end
