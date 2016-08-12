
/**
 * @file RHCApi.h
 * @author Huang Lei
 *
 ****************************************************************************************/

#import <Foundation/Foundation.h>
#import "RHCConn.h"
#import "RHCConfig.h"

@interface RHCApi : NSObject
/**
 @brief MQ URL
 */
@property (nonatomic,retain)NSString *baseURL;

/**
 @brief the mq user name
 */
@property (nonatomic,retain)NSString *mqName;
/**
 @brief the mq password
 */
@property (nonatomic,retain)NSString *mqPwd;

@property (nonatomic,retain)NSString *vHost;

/**
 @brief init method
 @param URL url
 @param port prot
 @param name MQ name
 @param pwd MQ password
 @param vhostName MQ vhost name
 @returns init object
 */
- (id)initWithURL:(NSString *)URL Port:(int)port MQName:(NSString *)name MQPwd:(NSString *)pwd vhost:(NSString *)vhostName;


#pragma  mark -Exchange

///**
// @brief get exchange list of a Vhost
// @param hostName Vhost name
// @returns the array include all exchange of a vhost
// */
//- (NSArray *)getExchangeOfVhost:(NSString *)hostName;
//
///**
// @brief get all exchange of a mq server
// @returns the array of all exchange of the mq server
// */
//- (NSArray *)getAllExchange;
//
///**
// @brief get A list of all bindings in which a given exchange is the source.
// @param exchange exchange name
// @returns a bindings Array
// */
//- (NSArray *)getBindingsOfExchangeSource:(NSString *)exchange;
//
//
///**
// @brief get A list of all bindings in which a given exchange is the destination.
// @param exchange exchange name
// @returns a bindings Array
// */
//- (NSArray *)getBindingsOfExchangeDestination:(NSString *)exchange;
//
///**
// @brief creat a new exchange for a vhost
// @param name exchange name
// @param vhostName vhost name
// @param type exchange name
// @param isAutoDelete isAutoDelete
// @param isDurable isDurable
// @param argument other argument
// @returns BOOL value YES or NO
// */
//- (BOOL)creatExchangeWithName:(NSString *)name vhost:(NSString *)vhostName type:(NSString *)type autoDelete:(BOOL)isAutoDelete durable:(BOOL)isDurable arguments:(NSArray *)argument;

#pragma mark - Queues
///**
// @brief A list of all queues.
// @returns a queue Array
// */
//- (NSArray *)getAllQueues;
//
///**
// @brief A list of all queues in a given virtual host.
// @returns a queue Array
// */
//- (NSArray *)getQueuesOfVhost;
//
///**
// @brief creat An individual queue
// @param queueName queueName
// @param vhost Vhost Name
// @returns BOOL value YES or NO
// */

- (BOOL)creatQueues:(NSString *)queueName withNode:(NSString *)node autoDelete:(BOOL)isAutoDelete durable:(BOOL)isDurable;

/**
 @brief delete An individual queue
 @param queueName queueName
 @param vhost Vhost Name
 @returns BOOL value YES or NO
 */
- (BOOL)deleteQueues:(NSString *)queueName;


#pragma mark - Bindings
///**
// @brief get A list of all bindings.
// @returns a binding Array
// */
//- (NSArray *)getAllBindings;
///**
// @brief get A list of all bindings in a given virtual host.
// @returns a binding Array
// */
//- (NSArray *)getBindingsOfVhost;
//
///**
// @brief A list of all bindings between an exchange and a queue. may many times!
// @param exchange a exchange Name
// @param queue a queue Name
// @returns a binding Array
// */
//- (NSArray *)getBindingsOfExchange:(NSString *)exchangeName queues:(NSString *)queueName;

/**
 @brief creat An individual binding between an exchange and a queue
 @param exchangeName exchangeName
 @param queueName queueName
 @param routing_key  The props part of the URI is a "name" for the binding composed of its routing key and properties.
 @returns BOOL value YES or NO
 */
- (BOOL)creatBindingsOfExchange:(NSString *)exchangeNames queues:(NSString *)queueName routing_key:(NSString *)key;

#pragma mark - Send && recive Method
/**
 @brief send message to server
 @param message message
 @param routingKey routing_key
 @param exchange exchange
 @returns BOOL Vaule YES or NO
 */
- (BOOL)sendMessage:(NSString *)message byRoutingKey:(NSString *)routingKey Exchange:(NSString *)exchange;


/**
 @brief recive message array form server
 @param queues queue
 @param vhost vhost
 @returns a message Array
 */
- (NSArray *)receiveMessageFromQueues:(NSString *)queues;
@end
