
/**
 * @file RHCConn.h
 * @author Huang Lei
 *
 ****************************************************************************************/

#import <Foundation/Foundation.h>

enum
{
    RCH_CREATQUEUE = 1, //创建队列
    RHC_BINDINGQUEUE, // 绑定队列
    RHC_DELETEQUEUE, // 删除队列
    RHC_SENDMESSAGE, // 发送消息
    RHC_RECEIVEMESSAGE //接收消息

}RHCHTTPTYPE;

@interface RHCConn : NSObject<NSURLConnectionDelegate>
/**
 @brief 用于 http请求的Connection
 */
@property (nonatomic,retain)NSURLConnection *httpConn;

/**
	@brief 网络请求的类型
 */
@property (nonatomic,assign)int RHCType;
/**
 @brief 标记异步的http请求是否完成
 */
@property (nonatomic,assign)BOOL httpsFinished;

/**
 @brief http请求返回的Dic结果
 */
@property (nonatomic,retain)id httpReturn;


/**
 @brief 接收到从Server返回的Data数据
 */
@property (nonatomic,retain)NSMutableData *receivedData;

/**
 @brief  超时定时器
 */
@property (nonatomic,retain)NSTimer *timeOutTimer;


@property (nonatomic,retain)NSString *userName;
@property (nonatomic,retain)NSString *passWord;


- (id)initWithMQName:(NSString *)name passWord:(NSString *)pwd withType:(int)type;

- (id)processRequest:(NSDictionary *)requestDic withURL:(NSString *)url HTTPMethod:(NSString *)httpMethod;

@end
