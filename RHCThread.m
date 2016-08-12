/**
 * @file RHCThread.m
 * @author Huang Lei
 *
 ****************************************************************************************/
#import "RHCThread.h"

@implementation RHCThread
@synthesize rhcApi;
@synthesize receiveQueueName;
@synthesize delegate;
@synthesize timeInterval;
#define TIMEINTERVAL 3

- (id)initwithRHCApi:(RHCApi *)tRhcApi withQueue:(NSString *)queueName
{
	if(self = [super init])
	{
		self.rhcApi = tRhcApi;
        self.receiveQueueName = queueName;
        self.timeInterval = TIMEINTERVAL;
	}

	return self;
}
- (void)dealloc
{
	[rhcApi release];

	[super dealloc];
}

- (void)main
{
	NSAutoreleasePool *localPool;

	while(![self isCancelled])
	{
        localPool = [[NSAutoreleasePool alloc] init];
        // 无消息轮训时休息间隔时间
        NSArray *receiveArray = [NSArray arrayWithArray:[self.rhcApi receiveMessageFromQueues:self.receiveQueueName]];
        if (receiveArray.count == 0)
        {
            // 等待X秒，继续轮训
            sleep(self.timeInterval);
            continue;
        }
        if ([self.delegate respondsToSelector:@selector(rpcConsumerThreadReceivedNewMessage:)])
        {
            [self.delegate rpcConsumerThreadReceivedNewMessage:receiveArray];
        }
        [localPool drain];
	}
}

@end
