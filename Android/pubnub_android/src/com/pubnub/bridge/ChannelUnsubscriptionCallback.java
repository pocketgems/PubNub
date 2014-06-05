package com.pubnub.bridge;

import com.pubnub.api.*;

public class ChannelUnsubscriptionCallback extends Callback {
    private static Logger log = new Logger(ChannelUnsubscriptionCallback.class);

    public void successCallback(String channel, Object response) {
        try {
            log.verbose("Successfully send message on channel " + channel + " " + response + " " + response.getClass());
            successCallback_native(channel, PubnubUtility.JSONString(response));
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public void errorCallback(String channel, PubnubError error) {
        try {
            log.verbose("Error sending message on channel " + channel + " " + error.errorCode);
            int errorCode = -1;
            if (PubnubErrorMap.errorMap.containsKey(error.errorCode)) {
                errorCode = PubnubErrorMap.errorMap.get(error.errorCode);
            }
            errorCallback_native(channel, errorCode, error.getErrorString());
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    @Override
    protected void finalize() throws Throwable {
        log.verbose("Deallocing " + this);
        super.finalize();
    }


    // Call Native methods
    private native void successCallback_native(String channel, String response);
    private native void errorCallback_native(String channel, int errorCode, String errorMessage);

    public native ChannelUnsubscriptionCallback retain_native();
    public native void release_native();

    public native void removeFromUnsubscriptionCallbackList_native(String channel);

}
