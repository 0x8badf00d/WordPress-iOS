/*
 * Theme.m
 *
 * Copyright (c) 2013 WordPress. All rights reserved.
 *
 * Licensed under GNU General Public License 2.0.
 * Some rights reserved. See license.txt
 */

#import "Theme.h"
#import "Blog.h"
#import "WordPressComApi.h"
#import "WordPressAppDelegate.h"

static NSDateFormatter *dateFormatter;

@implementation Theme

@dynamic popularityRank;
@dynamic details;
@dynamic themeId;
@dynamic premium;
@dynamic launchDate;
@dynamic screenshotUrl;
@dynamic trendingRank;
@dynamic version;
@dynamic tags;
@dynamic name;
@dynamic previewUrl;
@dynamic blog;

+ (Theme *)createOrUpdateThemeFromDictionary:(NSDictionary *)themeInfo withBlog:(Blog*)blog {
    NSManagedObjectContext *context = [WordPressAppDelegate sharedWordPressApplicationDelegate].managedObjectContext;
    
    Theme *theme;
    NSSet *result = [blog.themes filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self.themeId == %@", themeInfo[@"id"]]];
    if (result.count > 1) {
        theme = result.allObjects[0];
    } else {
        theme = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                              inManagedObjectContext:context];
        theme.themeId = themeInfo[@"id"];
        theme.blog = blog;
    }

    theme.name = themeInfo[@"name"];
    theme.details = themeInfo[@"description"];
    theme.trendingRank = themeInfo[@"trending_rank"];
    theme.popularityRank = themeInfo[@"popularity_rank"];
    theme.screenshotUrl = themeInfo[@"screenshot"];
    theme.version = themeInfo[@"version"];
    theme.premium = @([[themeInfo objectForKeyPath:@"cost.number"] integerValue] > 0);
    theme.tags = themeInfo[@"tags"];
    theme.previewUrl = themeInfo[@"preview_url"];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd";
    }
    theme.launchDate = [dateFormatter dateFromString:themeInfo[@"launch_date"]];
    
    return theme;
}

- (BOOL)isCurrentTheme {
    return [self.blog.currentThemeId isEqualToString:self.themeId];
}

- (BOOL)isPremium {
    return [self.premium isEqualToNumber:@(1)];
}

@end

@implementation Theme (PublicAPI)

+ (void)fetchAndInsertThemesForBlog:(Blog *)blog success:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[WordPressComApi sharedApi] fetchThemesForBlogId:blog.blogID.stringValue success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *themesToKeep = [NSMutableArray array];
        for (NSDictionary *t in responseObject[@"themes"]) {
            Theme *theme = [Theme createOrUpdateThemeFromDictionary:t withBlog:blog];
            [themesToKeep addObject:theme];
        }
        
        for (Theme *t in blog.themes) {
            if (![themesToKeep containsObject:t]) {
                [t.managedObjectContext deleteObject:t];
            }
        }

        [[WordPressAppDelegate sharedWordPressApplicationDelegate].managedObjectContext save:nil];
        dateFormatter = nil;
        
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)fetchCurrentThemeForBlog:(Blog *)blog success:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[WordPressComApi sharedApi] fetchCurrentThemeForBlogId:blog.blogID.stringValue success:^(AFHTTPRequestOperation *operation, id responseObject) {
        blog.currentThemeId = responseObject[@"id"];
        [[WordPressAppDelegate sharedWordPressApplicationDelegate].managedObjectContext save:nil];
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)activateThemeWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    [[WordPressComApi sharedApi] activateThemeForBlogId:self.blog.blogID.stringValue themeId:self.themeId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.blog.currentThemeId = self.themeId;
        [[WordPressAppDelegate sharedWordPressApplicationDelegate].managedObjectContext save:nil];
        
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end