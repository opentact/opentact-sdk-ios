//
//  OpentactUA.m
//  OpentactSDK
//
//  Created by hewx on 15/2/4.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

//#import <AVFoundation/AVAudioSession.h>
#import "OpentactUA.h"
#import "OpentactRest.h"

#define FILE_NAME "OpentactUA"

const size_t MAX_SIP_ID_LENGTH = 50;
const size_t MAX_SIP_REG_URI_LENGTH = 50;

static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata);
static void on_call_state(pjsua_call_id, pjsip_event *e);
static void on_call_media_state(pjsua_call_id call_id);
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info);
static void on_nat_detect(const pj_stun_nat_detect_result *res);
static void on_ice_transport_error(int index, pj_ice_strans_op op, pj_status_t status, void *param);

@interface OpentactUA()


@property pjsua_call_id call_id;
@property pjsua_acc_id acc_id;
@property (copy, nonatomic) void (^registerCallback)(BOOL);
@property (copy, nonatomic) void (^incomingCallCallback)(NSString *sid);
@property (copy, nonatomic) void (^hangonCallback)(void);
@property (copy, nonatomic) void (^hangupCallback)(void);
@property (copy, nonatomic) void (^ringCallback)(void);

@end

@implementation OpentactUA

static OpentactUA* sharedInstance = nil;

// Singleton
+ (OpentactUA *)sharedOpentactUA
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}


- (BOOL)registerToDomain:(NSString *)domain
                withUser:(NSString *)user
             andPassword:(NSString *)password
              onRegister:(void (^)(BOOL))registerCallback
          onIncomingCall:(void (^)(NSString *sid))incomingCallCallback
                onHangon:(void (^)(void))hangonCallback
                onHangup:(void (^)(void))hangupCallback
                  onRing:(void (^)(void))ringCallback
{
    pj_status_t status;
    
    // Create pjsua
    status = pjsua_create();
    if (status != PJ_SUCCESS)
    {
        pjsua_perror(FILE_NAME, "Error in pjsua_create()", status);
        return NO;
    }
    
    NSLog(@"Starting initial pjsua");
    
    self.registerCallback = registerCallback;
    self.incomingCallCallback = incomingCallCallback;
    self.hangupCallback = hangupCallback;
    self.hangonCallback = hangonCallback;
    self.ringCallback = ringCallback;
    
    {
        pjsua_config cfg;
        pjsua_media_config media_cfg;
        pjsua_config_default(&cfg);
        pjsua_media_config_default(&media_cfg);
        
        media_cfg.ec_options = PJMEDIA_ECHO_DEFAULT;
        
        cfg.cb.on_incoming_call = &on_incoming_call;
        cfg.cb.on_call_media_state = &on_call_media_state;
        cfg.cb.on_call_state = &on_call_state;
        cfg.cb.on_reg_state2 = &on_reg_state2;
        cfg.cb.on_nat_detect = &on_nat_detect;
        cfg.cb.on_ice_transport_error = &on_ice_transport_error;
        
    
        cfg.stun_srv_cnt = 1;
        cfg.stun_srv[0] = pj_str("108.165.2.111:3478");
        cfg.stun_ignore_failure = PJ_FALSE;
    
        
        media_cfg.enable_ice = PJ_TRUE;
        media_cfg.enable_turn = PJ_TRUE;
        
        media_cfg.turn_server = pj_str("108.165.2.111:3478");
        media_cfg.turn_conn_type = PJ_TURN_TP_TCP;
        media_cfg.turn_auth_cred.type = PJ_STUN_AUTH_CRED_STATIC;
        media_cfg.turn_auth_cred.data.static_cred.realm = pj_str("opentact");
        media_cfg.turn_auth_cred.data.static_cred.username = pj_str("opentact");
        media_cfg.turn_auth_cred.data.static_cred.data_type = PJ_STUN_PASSWD_PLAIN;
        media_cfg.turn_auth_cred.data.static_cred.data = pj_str("opentact@123456");
        
    
        
        // Init the logging config structure
        pjsua_logging_config log_cfg;
        pjsua_logging_config_default(&log_cfg);
        log_cfg.console_level = 4;
        
        
        // init the pjsua
        status = pjsua_init(&cfg, &log_cfg, &media_cfg);
        
        if (status != PJ_SUCCESS) {
            pjsua_perror(FILE_NAME, "Error in pjsua_init()", status);
            return NO;
        }
    }
    
    // Add UDP transport.
    {
        // Init transport config structure
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
        cfg.port = 5080;
        
        status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
        if (status != PJ_SUCCESS) {
            pjsua_perror(FILE_NAME, "Error in creating udp transport()", status);
            return NO;
        }
    }
    
    // Add TCP transport.
//    {
//        // Init transport config structure
//        pjsua_transport_config cfg;
//        pjsua_transport_config_default(&cfg);
//        cfg.port = 5080;
//        
//        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &cfg, NULL);
//        if (status != PJ_SUCCESS) {
//            pjsua_perror(FILE_NAME, "Error in creating tcp transport()", status);
//            return NO;
//        }
//    }
    
    
    // Initialization is done, now start pjsua
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
        pjsua_perror(FILE_NAME, "Error in pjsua_start()", status);
        return NO;
    }
    
    // Register the account on sip server
    {
        pjsua_acc_config cfg;
        pjsua_acc_config_default(&cfg);
        
        const char *csipUser = [user UTF8String];
        const char *csipDomain = [domain UTF8String];
        const char *csipPassword = [password UTF8String];
        
        // Account ID
        char sipId[MAX_SIP_ID_LENGTH];
        sprintf(sipId, "sip:%s@%s", csipUser, csipDomain);
        cfg.id = pj_str(sipId);
        
        // Reg URI
        char regUri[MAX_SIP_REG_URI_LENGTH];
        //sprintf(regUri, "sip:%s;transport=tcp", csipDomain);
        sprintf(regUri, "sip:%s", csipDomain);
        cfg.reg_uri = pj_str(regUri);
        
        
        cfg.reg_retry_interval = 120;
        cfg.reg_first_retry_interval = 120;
        cfg.reg_timeout = 120;
        
        
        pj_str_t codec_s;
        
        pjsua_codec_set_priority(pj_cstr(&codec_s, "iLBC/8000/1"), PJMEDIA_CODEC_PRIO_HIGHEST);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "G729/8000/1"), PJMEDIA_CODEC_PRIO_NEXT_HIGHER);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "PCMU/8000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "PCMA/8000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "GSM/8000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "SPEEX/8000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "SPEEX/16000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        pjsua_codec_set_priority(pj_cstr(&codec_s, "SPEEX/32000/1"), PJMEDIA_CODEC_PRIO_DISABLED);
        
        // Account cred info
        cfg.cred_count = 1;
        cfg.cred_info[0].scheme = pj_str("digest");
        cfg.cred_info[0].realm = pj_str("Dialer");
        cfg.cred_info[0].username = pj_str((char *)csipUser);
        cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        cfg.cred_info[0].data = pj_str((char *)csipPassword);
        
        
        status = pjsua_acc_add(&cfg, PJ_TRUE, &_acc_id);
        if (status != PJ_SUCCESS) {
            pjsua_perror(FILE_NAME, "Error in adding account", status);
            return NO;
        }
    }
    
    // enable speaker
//    {
//        pjmedia_aud_dev_route route = PJMEDIA_AUD_DEV_ROUTE_LOUDSPEAKER;
//        pj_status_t status = pjsua_snd_set_setting(PJMEDIA_AUD_DEV_CAP_OUTPUT_ROUTE, &route, PJ_FALSE);
//        if (status != PJ_SUCCESS) {
//            pjsua_perror(FILE_NAME, "Error in enabling speaker phone", status);
//            return NO;
//        }
//    }
    
    NSLog(@"Finish initial pjsua");
    
    
    return YES;
}

- (BOOL)dialToUri: (NSString *)uri
{
    NSLog(@"Making call to %@", uri);
    const char *cUri = [uri cStringUsingEncoding:NSUTF8StringEncoding];
    
    pj_status_t status;
    pj_str_t sipUri = pj_str((char *)cUri);
    
    status = pjsua_call_make_call(_acc_id, &sipUri, 0, NULL, NULL, NULL);
    
    if (status != PJ_SUCCESS) {
        pjsua_perror(FILE_NAME, "Error making call", status);
        return NO;
    }
    return YES;
}

- (void)answer
{
    NSLog(@"Answering cal: %d", self.call_id);
    if (self.call_id) {
        pjsua_call_answer(self.call_id, 200, NULL, NULL);
    }
    self.call_id = 0;
}

- (void)hangup
{
    pjsua_call_hangup_all();
}

- (void)keepAlive
{
    if (!pj_thread_is_registered()) {
        static pj_thread_desc thread_desc;
        static pj_thread_t *thread;
        pj_thread_register("mainthread", thread_desc, &thread);
    }
    
    pj_thread_sleep(5000);
}



@end


/* callback called by the library upon receving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id,
                             pjsua_call_id call_id,
                             pjsip_rx_data *rdata)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    PJ_LOG(3, (FILE_NAME, "Incoming call from %.*s!!",
               (int)ci.remote_info.slen,
               ci.remote_info.ptr));
    
    OpentactUA *ua = [OpentactUA sharedOpentactUA];
    ua.call_id = call_id;
    
    // return 180 ringing
    pjsua_call_answer(call_id, 180, NULL, NULL);
    
    /* TODO: get sid */
    NSString *str = [NSString stringWithUTF8String:ci.remote_info.ptr];
    NSRange startRange = [str rangeOfString:@":"];
    NSRange endRange = [str rangeOfString:@"@"];
    
    NSUInteger start = startRange.location;
    NSUInteger end = endRange.location;
    
    NSString *number = [[str substringToIndex:end] substringFromIndex:start+1];
    
    OpentactRest *rest = [OpentactRest sharedOpentactRest];
    [rest sipAccountByNumber:number withSuccess:^(id data) {
        NSDictionary *resDict = (NSDictionary *)data;
        NSString *sid = [resDict objectForKey:@"sid"];
        OpentactUA *ua = [OpentactUA sharedOpentactUA];
        dispatch_async(dispatch_get_main_queue(), ^{
            ua.incomingCallCallback(sid);
        });
    }];
}

/* Callback called by the library when registartion state has changed */
static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info)
{
    OpentactUA *ua = [OpentactUA sharedOpentactUA];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        switch(info->cbparam->code)
        {
            case 200:
                ua.registerCallback(YES);
                break;
            case 401:
                ua.registerCallback(NO);
                break;
            default:
                break;
        }
    });
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        
    }
}


/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info ci;
    
    PJ_UNUSED_ARG(e);
    
    pjsua_call_get_info(call_id, &ci);
    PJ_LOG(3,(FILE_NAME, "Call %d state=%.*s", call_id,
              (int)ci.state_text.slen,
              ci.state_text.ptr));
    OpentactUA *ua = [OpentactUA sharedOpentactUA];
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ua.hangupCallback();
        });
    }
    else if (ci.state == PJSIP_INV_STATE_CONFIRMED) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ua.hangonCallback();
        });
    }
    else if (ci.state == PJSIP_INV_STATE_EARLY) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ua.ringCallback();
        });
    }
    
}

/* NAT type dectection callback. */
static void on_nat_detect(const pj_stun_nat_detect_result *res)
{
    if (res->status != PJ_SUCCESS) {
        pjsua_perror(FILE_NAME, "NAT dectection failed", res->status);
    } else {
        PJ_LOG(2, (FILE_NAME, "NAT detected as %s", res->nat_type_name));
    }
}

/* Notification On ICE error */
static void on_ice_transport_error(int index, pj_ice_strans_op op, pj_status_t status, void *param)
{
    PJ_UNUSED_ARG(op);
    PJ_UNUSED_ARG(param);
    PJ_PERROR(1, (FILE_NAME, status, "ICE keep alive failure for transport %d", index));
}
