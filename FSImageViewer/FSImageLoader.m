//  FSImageViewer
//
//  Created by Felix Schulze on 8/26/2013.
//  Copyright 2013 Felix Schulze. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOCache.h"
#import "FSImageLoader.h"
@implementation FSImageLoader {
    NSMutableArray *runningRequests;
}

+ (FSImageLoader *)sharedInstance {
    static FSImageLoader *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FSImageLoader alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 30.0;
        runningRequests = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)dealloc {
}

- (void)cancelAllRequests {
}

- (void)cancelRequestForUrl:(NSURL *)aURL {
}

- (void)loadImageForURL:(NSURL *)aURL image:(void (^)(UIImage *image, NSError *error))imageBlock {

    if (!aURL) {
        NSError *error = [NSError errorWithDomain:@"de.felixschulze.fsimageloader" code:412 userInfo:@{
                NSLocalizedDescriptionKey : @"You must set a url"
        }];
        imageBlock(nil, error);
    };
    NSString *cacheKey = [NSString stringWithFormat:@"FSImageLoader-%@", aURL];

    UIImage *anImage = [[EGOCache globalCache] imageForKey:cacheKey];

    if (anImage) {
        if (imageBlock) {
            imageBlock(anImage, nil);
        }
    }
    else {
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:aURL
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if (!error) {
                        UIImage * image = [UIImage imageWithData:data];
                        [[EGOCache globalCache] setImage:image forKey:cacheKey];
                        if (imageBlock) {
                            imageBlock(image, nil);
                        }
                    }
                }] resume];
    }
}
@end
