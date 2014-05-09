package com.pocketgems.pgengine.pubnub;

import com.pocketgems.android.pgcommon.PGLog;
import com.pocketgems.pgengine.pubnub.PubnubUtility;
import com.pubnub.api.*;

/**
 * Created by Ravi on 3/19/14.
 */
public class MessageProcessingCallback extends Callback {

    private static final String LOG_TAG = "MessageProcesingCallback";

    public void successCallback(String channel, Object response) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Send message on channel success" + " " + channel + " " + response + " " + response.getClass());
            successCallback_native(channel, PubnubUtility.JSONString(response));
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public void errorCallback(String channel, PubnubError error) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Send message on channel error" + " " + channel + " " + error.errorCode);

            int errorCode = -1;
            if (PubnubErrorMap.errorMap.containsKey(error.errorCode)) {
                errorCode = PubnubErrorMap.errorMap.get(error.errorCode);
            }
            errorCallback_native(channel, errorCode, error.getErrorString());
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    @Override
    protected void finalize() throws Throwable {
        PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Deallocing " + this);
        super.finalize();
    }

    // Native methods to be called

    private native void successCallback_native(String channel, String response);
    private native void errorCallback_native(String channel, int errorCode, String errorMessage);

    public native MessageProcessingCallback retain_native();
    public native void release_native();

}
