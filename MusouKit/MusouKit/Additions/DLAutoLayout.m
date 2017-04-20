
#import "DLAutoLayout.h"
#import <objc/runtime.h>


#define AL_VALUE_BLOCK ^(CGFloat c)


@implementation UIView (AutoLayout)

- (void)dl_setToView:(UIView *)v{
    objc_setAssociatedObject(self, "toView", v, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)dl_toView{
    return objc_getAssociatedObject(self, "toView");
}

- (void)dl_setParent:(UIView *)parent{
    objc_setAssociatedObject(self, "parent", parent, OBJC_ASSOCIATION_ASSIGN);
}

- (UIView *)dl_parent{
    return objc_getAssociatedObject(self, "parent");
}

- (NSMutableDictionary *)dl_constraintInfo{
    NSMutableDictionary *info = objc_getAssociatedObject(self, "constraintInfo");
    if (!info){
        info = [NSMutableDictionary new];
        objc_setAssociatedObject(self, "constraintInfo", info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return info;
}

- (NSLayoutConstraint *)dl_lastConstraint{
    return [[self dl_constraintInfo] objectForKey:@(-100)];
}

- (NSLayoutConstraint *)dl_constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(nullable id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c{
    
    NSLayoutConstraint *cst = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
    cst.priority = 999;
    [[self dl_constraintInfo] setObject:cst forKey:@(attr1)];
    [[self dl_constraintInfo] setObject:cst forKey:@(-100)];
    return cst;
}

- (instancetype)dl_reset{
    UIView *view = self;
    UIView *parent = view.superview;
    NSInteger idx = [view.superview.subviews indexOfObject:view];
    [view removeFromSuperview];
    [parent insertSubview:view atIndex:idx];
    [[self dl_constraintInfo] removeAllObjects];
    return self;
}

- (ALValueBlock)priority{
    return ^(CGFloat c){
        
        [self dl_lastConstraint].priority = c;
        return self;
    };
}

- (ALValueBlock)multiplier{
    return ^(CGFloat c){
        
        [[self dl_lastConstraint] setValue:@(c) forKey:@"multiplier"];
        return self;
    };
}

- (ALReleationBlock)relation{
    return ^(NSLayoutRelation rel){
        
        [[self dl_lastConstraint] setValue:@(rel) forKey:@"relation"];
        return self;
    };
}

- (ALValueBlock)width{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeWidth
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeWidth
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)height{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeHeight
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeHeight
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)edge{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        view.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *metrics = @{@"t":@(c),@"l":@(c),@"b":@(c),@"r":@(c)};
        [self.dl_parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-t-[view]-b-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        [self.dl_parent addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-l-[view]-r-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(view)]];
        
        return self;
    };
}

- (ALValueBlock)leading{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeTrailing : NSLayoutAttributeLeading;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeLeading
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)trailing{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeTrailing
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)left{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeRight : NSLayoutAttributeLeft;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeLeft
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)right{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeRight
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)top{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeBottom : NSLayoutAttributeTop;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeTop
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)bottom{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        NSLayoutAttribute attr = self.dl_toView ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeBottom
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:attr
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignLeft{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeLeft
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeLeft
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignRight{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeRight
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeRight
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignTop{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeTop
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeTop
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignBottom{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeBottom
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeBottom
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignCenterX{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeCenterX
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeCenterX
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignCenterY{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeCenterY
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeCenterY
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALValueBlock)alignBaseline{
    return AL_VALUE_BLOCK{
        
        UIView *view = self;
        UIView *toView = self.dl_toView ? self.dl_toView : self.dl_parent;
        [self
         dl_constraintWithItem:view
         attribute:NSLayoutAttributeBaseline
         relatedBy:NSLayoutRelationEqual
         toItem:toView
         attribute:NSLayoutAttributeBaseline
         multiplier:1.0
         constant:c];
        
        return self;
    };
}

- (ALViewBlock)dl_relativeTo{
    return ^(UIView *v){
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self dl_setToView:v];
        return self;
    };
}

- (ALViewBlock)dl_begin{
    return ^(UIView *v){
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self dl_setParent:v];
        return self;
    };
}

- (ALVoidBlock)dl_end{
    return ^{
        
        NSDictionary *cs = [self dl_constraintInfo];
        for (NSNumber *key in cs) {
            if ([key integerValue] != -100){
                [self.dl_parent addConstraint:cs[key]];
            }
        }
        
        [self dl_setParent:nil];
        [self dl_setToView:nil];
    };
}

- (NSLayoutConstraint *)dl_findConstraint:(NSLayoutAttribute)attr{
    return [self dl_constraintInfo][@(attr)];
}

@end

