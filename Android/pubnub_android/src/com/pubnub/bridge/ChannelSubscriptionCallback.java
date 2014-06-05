package com.pubnub.bridge;

import com.pubnub.api.*;

public class ChannelSubscriptionCallback extends Callback {
    private static Logger log = new Logger(ChannelSubscriptionCallback.class);

    @Override
    public void connectCallback(String channel, Object message) {
        try {
            log.verbose("Connected on channel " + channel + " " + message + " " + message.getClass());
            connectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    @Override
    public void disconnectCallback(String channel, Object message) {
        try {
            log.verbose("Disconnected from channel " + channel + " " + message + " " + message.getClass());
            disconnectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public void reconnectCallback(String channel, Object message) {
        try {
            log.verbose("Reconnecting on channel " + channel + " " + message + " " + message.getClass());
            reconnectCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    @Override
    public void successCallback(String channel, Object message) {
        try {
            log.verbose("Successfully subscribed to channel " + channel + " " + message + " " + message.getClass());
            successCallback_native(channel, PubnubUtility.JSONString(message));
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    @Override
    public void errorCallback(String channel, PubnubError error) {
        try {
            log.verbose("Error subscribing on channel " + channel + " " + error.errorCode);
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
