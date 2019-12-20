//
//  WebSocketManager.h
//  DSDNextProject
//
//  Created by fengpan on 2019/5/6.
//  Copyright © 2019 fengpan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class WebSocketManager;

@protocol WebSocketManagerDelegate <NSObject>


@required
-(void)webSocket:(WebSocketManager *)webSocket MarketID:(NSInteger)ID array:(NSMutableArray *)array dict:(NSDictionary *)dict;

@optional
-(void)webSocketDidDisconnect:(WebSocketManager *)webSocket Error:(NSError *)error;

@end

@interface WebSocketManager : NSObject

/** 代理*/
@property (nonatomic, weak) id<WebSocketManagerDelegate>delegate;

+ (WebSocketManager *)shareInstance;

-(void)connect;

-(void)disconnect;

@end

NS_ASSUME_NONNULL_END
