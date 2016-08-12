/**
 * @file RHCThread.h
 * @author Huang Lei
 *
 ****************************************************************************************/
#import <Foundation/Foundation.h>
#import "RHCApi.h"
@class RHCThread;
@class AMQPMessage;

@protocol RHCConsumerThreadDelegate

- (void)rpcConsumerThreadReceivedNewMessage:(NSArray*)meesgeArray;
@end

@interface RHCThread : NSThread
{


	NSObject<RHCConsumerThreadDelegate> *delegate;
}

@property (assign) NSObject<RHCConsumerThreadDelegate> *delegate;
@property (nonatomic,retain)RHCApi *rhcApi;
@property (nonatomic,copy)NSString *receiveQueueName;
@property (nonatomic,assign)int timeInterval;
- (id)initwithRHCApi:(RHCApi *)tRhcApi withQueue:(NSString *)queueName;
- (void)dealloc;

- (void)main;
@end
