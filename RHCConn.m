/**
 * @file RHCConn.m
 * @author Huang Lei
 *
 ****************************************************************************************/
#import "RHCConn.h"
#import "JSON.h"
#import "MMEncrypt.h"
#import "MMLog.h"
#import "RHCConfig.h"

@implementation RHCConn
@synthesize httpConn;
@synthesize httpReturn;
@synthesize timeOutTimer;
@synthesize httpsFinished;
@synthesize receivedData;
@synthesize userName;
@synthesize passWord;
@synthesize RHCType;

- (id)initWithMQName:(NSString *)name passWord:(NSString *)pwd withType:(int)type
{
    if (self =[super init])
    {
        self.userName = name;
        self.passWord = pwd;
        self.RHCType = type;
    }

    return self;
}
- (void)dealloc
{
    [userName release];
    [passWord release];
    [receivedData release];
    [timeOutTimer release];
    [httpReturn release];
    [httpConn release];
    [super dealloc];
}

#pragma mark -
#pragma mark HTTPS && HTTP Method

// http超时处理
- (void)httpsTimeOutConnection
{
    [MMLog logW:@" RHCConn [httpsTimeOutConnection] http time out!!!"];
    if (self.timeOutTimer)
    {
        [self.timeOutTimer invalidate];
    }
    self.httpsFinished = YES;
    [self.httpConn cancel];
}

- (id)processRequest:(NSDictionary *)requestDic withURL:(NSString *)url HTTPMethod:(NSString *)httpMethod
{
    self.httpReturn = nil;
    // 将所得的Dic进行封包操作
    NSString *postString = [requestDic JSONRepresentation];
    if ([self.userName length] == 0 || [self.passWord length] == 0)
    {
        // 预防 userName 和password为空的情况
        [MMLog logE:@" RHCConn [processRequest] userName or passWord nil Error! userName:%@,passWord:%@",self.userName,self.passWord];
        return self.httpReturn;
    }
    // 用户名和密码
    NSString *authorString = [NSString stringWithFormat:@"%@:%@",self.userName,self.passWord];
    NSData *encryptData = [authorString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *enCodeAuthorString = [MMEncrypt base64Encode:encryptData];
    NSString *encryptAuthor =[NSString stringWithFormat:@"Basic %@",enCodeAuthorString];

    // 封装HTTP进行发送
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    // http
    NSMutableURLRequest *requests = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                              timeoutInterval:RHC_TIMEOUTINTERVAL] autorelease];
    // 设置请求方式
    if ([httpMethod isEqualToString:@"POST"]) {
        [requests setHTTPMethod:@"POST"];
    }
    else if([httpMethod isEqualToString:@"GET"])
    {
        [requests setHTTPMethod:@"GET"];
    }
    else if([httpMethod isEqualToString:@"PUT"])
    {
        [requests setHTTPMethod:@"PUT"];
    }
    else if([httpMethod isEqualToString:@"DELETE"])
    {
        [requests setHTTPMethod:@"DELETE"];
    }
    else
    {
        return nil;
    }

    [requests addValue:encryptAuthor forHTTPHeaderField:@"Authorization"];
    [requests setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [requests setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [requests setHTTPBody:postData];
    [requests setValue:postLength forHTTPHeaderField:@"Content-Length"];

    // 标记等待http请求
    self.httpsFinished = NO;
    // 连接发送请求
    self.httpConn  = [NSURLConnection connectionWithRequest:requests delegate:self];
    // 添加超时Timer
    self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:RHC_TIMEOUTINTERVAL
                                                         target: self
                                                       selector: @selector(httpsTimeOutConnection)
                                                       userInfo:nil
                                                        repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timeOutTimer forMode:NSDefaultRunLoopMode];
    // 堵塞线程，等待结束
    while(!self.httpsFinished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    // 停止定时器
    if (self.timeOutTimer) {
        [self.timeOutTimer invalidate];
    }
    //  如果未返回，有可能超时或者没返回
    if ([self.httpReturn isKindOfClass:[NSNull class]])
    {
        [MMLog logW:@" RHCConn [processRequest] return Value is Null!"];
        return nil;
    }
    return self.httpReturn;
}


#pragma mark -
#pragma mark - NSURLConnectionDeleagte
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse*)response
{
    //  释放之前数据
    if (self.receivedData != nil)
    {
        self.receivedData = nil;
    }
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode > 300)
    {
        [MMLog logW:@" RHCConn [didReceiveResponse]the RHCHTTPTYPE is%d,response status is %d",self.RHCType,httpResponse.statusCode];
    }

    // 此三种请求不管成功与否都不会返回信息，所以要通过http请求的statuscode来判断是否成功，并以Dic返回
    if (self.RHCType == RCH_CREATQUEUE || self.RHCType == RHC_DELETEQUEUE || self.RHCType == RHC_BINDINGQUEUE)
    {
        if (httpResponse.statusCode < 300 && httpResponse.statusCode >= 200)
        {
            self.httpReturn = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"routed",nil];
        }
        else
        {
            self.httpReturn = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"routed",nil];
        }
    }
    else if(self.RHCType == RHC_RECEIVEMESSAGE)
    {
        self.httpReturn = [NSArray array];
    }
    else if(self.RHCType == RHC_SENDMESSAGE)
    {
        self.httpReturn = [NSDictionary dictionary];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.httpsFinished = YES;
    self.httpReturn = nil;
    [MMLog logE:@" RHCConn [didFailWithError] HTTPS Error is %@",error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 如果为空，则初始化receivedData
    if (self.receivedData == nil){
        self.receivedData = [NSMutableData dataWithCapacity:100];
    }
    // 将data进行拼接
    [self.receivedData appendData:data];
}

// 接收完成，处理数据
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 分error code进行返回
    if (self.receivedData)
    {
        NSString *results = [[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease];
        self.httpReturn = [results JSONValue];
    }
    // 调用已经完成
    self.httpsFinished = YES;
}

@end
