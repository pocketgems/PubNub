package com.pocketgems.pgengine.pubnub;

import com.pocketgems.android.pgcommon.PGLog;
import com.pocketgems.pgengine.pubnub.PubnubUtility;
import com.pubnub.api.*;

/**
 * Created by Ravi on 3/19/14.
 */

public class ChannelSubscriptionCallback extends Callback {

    private static final String LOG_TAG = "ChannelSubscriptionCallback";

    @Override
    public void connectCallback(String channel, Object message) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel Connected" + " " + channel + " " + message + " " + message.getClass());

            connectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    @Override
    public void disconnectCallback(String channel, Object message) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel disconnected" + " " + channel + " " + message + " " + message.getClass());

            disconnectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public void reconnectCallback(String channel, Object message) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel reconnect" + " " + channel + " " + message + " " + message.getClass());

            reconnectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    @Override
    public void successCallback(String channel, Object message) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel success" + " " + channel + " " + message + " " + message.getClass());

            successCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    @Override
    public void errorCallback(String channel, PubnubError error) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel error" + " " + channel + " " + error.errorCode);

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
    private native void connectCallback_native(String channel, String response);
    private native void disconnectCallback_native(String channel, String response);
    private native void reconnectCallback_native(String channel, String response);
    private native void successCallback_native(String channel, String response);
    private native void errorCallback_native(String channel, int errorCode, String errorMessage);

    public native ChannelSubscriptionCallback retain_native();
    public native void release_native();

    public native void removeFromSubscriptionCallbackList_native(String channel);

}
