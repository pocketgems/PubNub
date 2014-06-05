package com.pubnub.bridge;

import java.util.HashMap;
import com.pubnub.api.*;

public class PubnubErrorMap {

    public static HashMap<Integer, Integer> errorMap;
    static {
        errorMap = new HashMap<Integer, Integer>();
        errorMap.put(PubnubError.PNERR_TIMEOUT,                    110);
        errorMap.put(PubnubError.PNERR_PUBNUB_ERROR,                -1);
        errorMap.put(PubnubError.PNERR_CONNECT_EXCEPTION,           -1);
        errorMap.put(PubnubError.PNERR_HTTP_ERROR,                  -1);
        errorMap.put(PubnubError.PNERR_CLIENT_TIMEOUT,              -1);
        errorMap.put(PubnubError.PNERR_NETWORK_ERROR,               -1);
        errorMap.put(PubnubError.PNERR_PUBNUB_EXCEPTION,            -1);
        errorMap.put(PubnubError.PNERR_DISCONNECT,                  -1);
        errorMap.put(PubnubError.PNERR_DISCONN_AND_RESUB,           -1);
        errorMap.put(PubnubError.PNERR_GATEWAY_TIMEOUT,             -1);
        errorMap.put(PubnubError.PNERR_FORBIDDEN,                  117);
        errorMap.put(PubnubError.PNERR_UNAUTHORIZED,               116);
        errorMap.put(PubnubError.PNERR_SECRET_KEY_MISSING,          -1);
        errorMap.put(PubnubError.PNERR_ENCRYPTION_ERROR,            -1);
        errorMap.put(PubnubError.PNERR_DECRYPTION_ERROR,            -1);
        errorMap.put(PubnubError.PNERR_INVALID_JSON,               112);
        errorMap.put(PubnubError.PNERR_HTTP_RC_ERROR,               -1);
    }
}