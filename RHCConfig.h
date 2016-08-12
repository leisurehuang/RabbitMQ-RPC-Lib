
/**
 * @file RHCConfig.h
 * @author Huang Lei
 *
 ****************************************************************************************/

#ifndef RPC_HttpClient_Header_h
#define RPC_HttpClient_Header_h

// http Method
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_DELETE @"DELETE"

// Http Time Out Interval
#define RHC_TIMEOUTINTERVAL 20


// Receive Config
// allow recive message byte lenght
#define RECEIVE_BYTELENGHT (64*1024)

// whether the messages will be removed from the queue
#define RECEIVE_IS_REQUEUE NO

// receive message encoding
#define RECEIVE_ENCODING @"auto"

// one times recive message max count
#define RECEIVE_MESSAGE_MAX_COUNT @"5"


#endif
