
/**
 * @file RHCApi.m
 * @author Huang Lei
 *
 ****************************************************************************************/

#import "RHCApi.h"
#import "JSON.h"

@implementation RHCApi
@synthesize baseURL;
@synthesize mqName;
@synthesize mqPwd;
@synthesize vHost;


- (id)initWithURL:(NSString *)URL Port:(int)port MQName:(NSString *)name MQPwd:(NSString *)pwd vhost:(NSString *)vhostName
{
    if (self=[super init]) {
        self.baseURL = [NSString stringWithFormat:@"http://%@:%d/api",URL,port];
        self.mqName = name;
        self.mqPwd = pwd;
        self.vHost = vhostName;
    }
    return self;
}


- (void)dealloc
{
    [baseURL release];
    [vHost release];
    [mqName release];
    [mqPwd release];
    [super dealloc];
}


#pragma  mark -Exchange
/*
- (NSArray *)getExchangeOfVhost:(NSString *)hostName
{
    return nil;
}

- (NSArray *)getAllExchange
{
    return nil;

}

- (NSArray *)getBindingsOfExchangeSource:(NSString *)exchange
{
    return nil;
}

- (NSArray *)getBindingsOfExchangeDestination:(NSString *)exchange
{
    return nil;
}

- (BOOL)creatExchangeWithName:(NSString *)name vhost:(NSString *)vhostName type:(NSString *)type autoDelete:(BOOL)isAutoDelete durable:(BOOL)isDurable arguments:(NSArray *)argument
{
    return YES;
}
*/

#pragma mark - Queues
/*
- (NSArray *)getAllQueues
{
    return  nil;
}

- (NSArray *)getQueuesOfVhost
{
    return  nil;
}
*/

- (BOOL)creatQueues:(NSString *)queueName withNode:(NSString *)node autoDelete:(BOOL)isAutoDelete durable:(BOOL)isDurable
{
    /* /api/queues/vhost/name */
    /*{"auto_delete":false,"durable":true,"arguments":[],"node":"rabbit@smacmullen"}*/
    NSString *urlString = [NSString stringWithFormat:@"%@/queues/%@/%@",self.baseURL,self.vHost,queueName];
    NSNumber *auto_delete = [NSNumber numberWithBool:isAutoDelete];
    NSNumber *durable = [NSNumber numberWithBool:isDurable];
    NSArray *argument = [NSArray array];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         auto_delete,@"auto_delete",
                         durable,@"durable",
                         argument,@"arguments",
                   //      node,@"node",
                         nil];

    RHCConn *reciveConn = [[RHCConn alloc]initWithMQName:mqName passWord:mqPwd withType:RCH_CREATQUEUE];
    id returnDic = [reciveConn processRequest:dic withURL:urlString HTTPMethod:HTTP_METHOD_PUT];
    if ([returnDic isKindOfClass:[NSDictionary class]]&&[[returnDic objectForKey:@"routed"] boolValue])
    {
        [reciveConn release];
        return YES;
    }
    [reciveConn release];

    return NO;
}

- (BOOL)deleteQueues:(NSString *)queueName
{
    /* /api/queues/vhost/name */
    NSString *urlString = [NSString stringWithFormat:@"%@/queues/%@/%@",self.baseURL,self.vHost,queueName];
    RHCConn *reciveConn = [[RHCConn alloc]initWithMQName:mqName passWord:mqPwd withType:RHC_DELETEQUEUE];
    NSDictionary *returnDic = [reciveConn processRequest:nil withURL:urlString HTTPMethod:HTTP_METHOD_DELETE];
    if ([[returnDic objectForKey:@"routed"] boolValue])
    {
        [reciveConn release];
        return YES;
    }
    [reciveConn release];

    return NO;
}

#pragma mark - Bindings
/*
- (NSArray *)getAllBindings
{
    return nil;
}

- (NSArray *)getBindingsOfVhost
{
    return nil;
}

- (NSArray *)getBindingsOfExchange:(NSString *)exchangeName queues:(NSString *)queueName
{
    return nil;
}
 */
- (BOOL)creatBindingsOfExchange:(NSString *)exchangeNames queues:(NSString *)queueName routing_key:(NSString *)key
{
    /* /api/bindings/vhost/e/exchange/q/queue/props */
    /* {"routing_key":"my_routing_key","arguments":[]} */
    NSDictionary * propsDic = [NSDictionary dictionaryWithObjectsAndKeys:key,@"routing_key",[NSArray array],@"arguments",nil];
    NSString *urlString = [NSString stringWithFormat:@"%@/bindings/%@/e/%@/q/%@",self.baseURL,self.vHost,exchangeNames,queueName];
    BOOL flag = NO;
    RHCConn *reciveConn = [[RHCConn alloc]initWithMQName:mqName passWord:mqPwd withType:RHC_BINDINGQUEUE];
    NSDictionary *returnDic = [reciveConn processRequest:propsDic withURL:urlString HTTPMethod:HTTP_METHOD_POST];
    if ([[returnDic objectForKey:@"routed"] boolValue])
    {
        flag = YES;
    }
    else
    {
        flag =  NO;
    }
    [reciveConn release];

    return flag;
}


#pragma mark - Send && recive Method

- (BOOL)sendMessage:(NSString *)message byRoutingKey:(NSString *)routingKey Exchange:(NSString *)exchange
{
    /*http: //host:port/api/exchanges/test/chat/publish */
    NSString *urlString = [NSString stringWithFormat:@"%@/exchanges/%@/%@/publish",self.baseURL,self.vHost,exchange];
    BOOL flag = NO;
    NSDictionary *propertiesDic = [NSDictionary dictionaryWithObjectsAndKeys:nil];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         propertiesDic,@"properties",
                         routingKey,@"routing_key",
                         message,@"payload",
                         @"string",@"payload_encoding",
                         nil];
    RHCConn *reciveConn = [[RHCConn alloc]initWithMQName:mqName passWord:mqPwd withType:RHC_SENDMESSAGE];
    id returnDic = [reciveConn processRequest:dic withURL:urlString HTTPMethod:HTTP_METHOD_POST];
    if ([returnDic isKindOfClass:[NSDictionary class]]&&[[returnDic objectForKey:@"routed"] boolValue])
    {
        flag = YES;
    }
    else
    {
        flag =  NO;
    }
    [reciveConn release];

    return flag;
}

- (NSArray *)receiveMessageFromQueues:(NSString *)queues
{
    /*http: //host:port/api/queues/test/lei.huang/get*/
    if (queues ==nil || self.baseURL== nil || self.vHost==nil) {
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@/queues/%@/%@/get",self.baseURL,self.vHost,queues];

    NSNumber *byteLength = [NSNumber numberWithInt:RECEIVE_BYTELENGHT];
    NSNumber *boolnum = [NSNumber numberWithBool:RECEIVE_IS_REQUEUE];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         RECEIVE_MESSAGE_MAX_COUNT,@"count",
                         boolnum,@"requeue",
                         RECEIVE_ENCODING,@"encoding",
                         byteLength,@"truncate",
                         nil];

    RHCConn *reciveConn = [[RHCConn alloc]initWithMQName:mqName passWord:mqPwd withType:RHC_RECEIVEMESSAGE];
    id returnVaule = [reciveConn processRequest:dic withURL:urlString HTTPMethod:HTTP_METHOD_POST];
    NSArray *returnArray = nil;
    // make sure there will return a Array
    if ([returnVaule isKindOfClass:[NSArray class]])
    {
        returnArray = [NSArray arrayWithArray:returnVaule];
    }
    [reciveConn release];

    if ([returnArray count] > 0)
    {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
        NSDictionary *dic = nil;
        for (int i = 0; i < [returnArray count]; i++)
        {
            dic = [returnArray objectAtIndex:i];
            [array addObject:[dic objectForKey:@"payload"]];
        }

        return array;
    }

    return [NSArray array];
}

@end
