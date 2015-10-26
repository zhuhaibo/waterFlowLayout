//
//  UIImageView+Zoom.m
//  WaterFLayout
//
//  Created by qingqing on 15/4/28.
//  Copyright (c) 2015年 qingqing. All rights reserved.
//

#import "UIImageView+Zoom.h"
#import "SDWebImageManager.h"

UIImage * scale(UIImage *image, CGSize size)
{
    float scale = 1.0f;
    
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    float verticalRadio   = height * 1.0f / size.height;
    float horizontalRadio = width * 1.0f / size.width;
    
    if(verticalRadio > 1.0f && horizontalRadio > 1.0f)
        scale = verticalRadio > horizontalRadio ? verticalRadio : horizontalRadio;
    else if(verticalRadio > 1.0f || horizontalRadio > 1.0f)
        scale = verticalRadio < horizontalRadio ? horizontalRadio : verticalRadio;
    
    if(scale == 1.0f)
        return image;
    return [UIImage imageWithCGImage:image.CGImage scale:scale orientation:image.imageOrientation];
}

@interface UIImageView_Zoom()<UIScrollViewDelegate>
@end

@implementation UIImageView_Zoom

- (void)dealloc
{
    self.tapBlock = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 1.8f;
        self.showsVerticalScrollIndicator = YES;
        self.showsHorizontalScrollIndicator = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.userInteractionEnabled = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        
        // 点击事件
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

/**
 * 点击事件
 */
- (void)tapRecognizer:(UITapGestureRecognizer *)recognizer
{
    if(self.tapBlock)
        self.tapBlock(self);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ?(scrollView.bounds.size.width - scrollView.contentSize.width) / 2 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ?(scrollView.bounds.size.height - scrollView.contentSize.height) / 2 : 0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX,scrollView.contentSize.height / 2 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [scrollView setZoomScale:scale animated:YES];
}

@end

void zoom(CGRect rect, UIImage *image, NSString *urlString)
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect convertRect = rect;//[sender.superview convertRect:sender.frame toView:window];
    UIView *view = [[UIView alloc] initWithFrame:window.bounds];
    view.backgroundColor = [UIColor blackColor];
    [window addSubview:view];
    
    UIImageView_Zoom *zoomView = [[UIImageView_Zoom alloc] initWithFrame:view.bounds];
    zoomView.imageView.frame = convertRect;
    zoomView.imageView.image = image;
    [view addSubview:zoomView];
    
    NSURL *url = [NSURL URLWithString:urlString];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *cacheKey = [manager cacheKeyForURL:url];
    BOOL isCached = [manager cachedImageExistsForURL:url];
    if(isCached)
    {
        UIImage *image = [manager.imageCache imageFromDiskCacheForKey:cacheKey];
        image = scale(image, zoomView.bounds.size);
        zoomView.imageView.image = image;
        [UIView animateWithDuration:0.4f animations:^{
            zoomView.imageView.frame = CGRectMake(CGRectGetMidX(zoomView.bounds) - image.size.width / 2.0f, CGRectGetMidY(zoomView.bounds) - image.size.height / 2.0f, image.size.width, image.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            zoomView.imageView.frame = CGRectMake(CGRectGetMidX(zoomView.bounds) - convertRect.size.width / 2.0f, CGRectGetMidY(zoomView.bounds) - convertRect.size.height / 2.0f, CGRectGetWidth(convertRect), CGRectGetHeight(convertRect));
        } completion:^(BOOL finished) {
            if(finished)
            {
                [manager downloadImageWithURL:url options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    float progress = receivedSize * 1.0f / expectedSize;
                    NSLog(@">>>>>>>>>>progress %f", progress);
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if(finished)
                    {
                        if(image)
                        {
                            dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                                [manager.imageCache storeImage:image forKey:cacheKey toDisk:YES];
                            });
                            image = scale(image, zoomView.bounds.size);
                            zoomView.imageView.image = image;
                            [UIView animateWithDuration:0.4f animations:^{
                                zoomView.imageView.frame = CGRectMake(CGRectGetMidX(zoomView.bounds) - image.size.width / 2.0f, CGRectGetMidY(zoomView.bounds) - image.size.height / 2.0f, image.size.width, image.size.height);
                            }];
                        }
                    }
                }];
            }
        }];
    }
    zoomView.tapBlock = ^(UIImageView_Zoom *sender){
        CGRect frame = convertRect;
        frame.origin.x += sender.contentOffset.x;
        frame.origin.y += sender.contentOffset.y;
        [UIView animateWithDuration:0.4f animations:^(void){
            sender.imageView.frame = frame;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                sender.superview.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [sender.superview removeFromSuperview];
            }];
        }];
    };
}
