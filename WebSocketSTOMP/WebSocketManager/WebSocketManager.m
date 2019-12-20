//
//  WebSocketManager.m
//  DSDNextProject
//
//  Created by fengpan on 2019/5/6.
//  Copyright © 2019 fengpan. All rights reserved.
//
#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self;


#import "WebSocketManager.h"
#import "WebsocketStompKit.h"

@interface WebSocketManager ()<STOMPClientDelegate>
{
    NSTimeInterval reConnecTime;
    
}
@property (nonatomic, strong) STOMPClient *client;

@property (nonatomic, strong) NSURL *websocketUrl ;

@end

@implementation WebSocketManager

+ (WebSocketManager *)shareInstance{
    static dispatch_once_t onceToken;
    static WebSocketManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

-(void)connect{
    NSString *Authorization = [NSString stringWithFormat:@"Bearer 86fc2f92-092c-4fad-a19b-e2063211e346"];
    NSString *url = [NSString stringWithFormat:@"ws://124.115.228.215:8086/apps/cwebsocket/dsdclientsocket/websocket?deviceType=app&Authorization=%@",[self encodeToPercentEscapeString:Authorization]];
    
    self.websocketUrl = [NSURL URLWithString:url];
    STOMPClient *client = [[STOMPClient alloc] initWithURL:self.websocketUrl webSocketHeaders:@{} useHeartbeat:YES];
    if (self.client.connected == YES) { return; }
    NSLog(@"正在链接 = %@",url);

    //添加代理监听连接状态
    client.delegate = self;
    //建立连接
    self.client = client;
    WeakSelf(weakSelf)
    [client connectWithHeaders:@{} completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            [weakSelf reconnect];
        }else{

            // 广播，共有频道
            [client subscribeTo:@"/exchange/dsddefmarket" messageHandler:^(STOMPMessage *message) {
                NSLog(@"dsddefmarket = %@",message.body);
            }];
            // 广播，定向
            [client subscribeTo:@"/user/topic/dasdaomsg" messageHandler:^(STOMPMessage *message) {
                NSLog(@"dasdaomsg = %@",message.body);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 广播，区间交易
                [client subscribeTo:@"/exchange/dsdqjmarket" messageHandler:^(STOMPMessage *message) {
                    NSLog(@"dsdqjmarket = %@",message.body);
                }];
            });
        }
    }];
}

-(void)reconnect{
    [self disconnect];
    
    if (reConnecTime>32) { return; }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(reConnecTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.client = nil;
        [self connect];
    });
    
    //   重连时间2的指数级增长
    if (reConnecTime == 0) {
        reConnecTime = 2;
    }else{
        reConnecTime *= 2;
    }
    
}

- (void) websocketDidDisconnect:(NSError *)error{
    NSLog(@"--- %@--- error = ", error);
    [self reconnect];
}

-(void)disconnect{
    if (self.client) {
        [self.client disconnect];
        self.client.delegate = nil;
    }
}

- (NSString *)encodeToPercentEscapeString:(NSString *)input{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [input stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}

@end
