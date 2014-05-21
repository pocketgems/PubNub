package com.pubnub.api;

import java.util.UUID;

import com.pocketgems.android.pgcommon.PGLog;
import com.pocketgems.pgengine.pubnub.*;

import org.json.JSONObject;

/**
 * Pubnub object facilitates querying channels for messages and listening on
 * channels for presence/message events
 *
 * @author Pubnub
 *
 */

public class Pubnub extends PubnubCore {
    private static String LOG_TAG = "PubNubAndroid";

    /**
     * @param publish_key
     * @param subscribe_key
     * @param secret_key
     */
    public Pubnub(String publish_key, String subscribe_key, String secret_key) {
        super(publish_key, subscribe_key, secret_key, "", false);
    }

    protected String uuid() {
        return java.util.UUID.randomUUID().toString();
    }

    protected String getUserAgent() {
        return "(Android " + android.os.Build.VERSION.RELEASE +
               "; " + android.os.Build.MODEL +
               " Build) PubNub-Java/Android/" + VERSION;
    }

    // Static Methods

    static Pubnub __sharedInstance = null;
    public static void initialializePubnub(String publish_key, String subscribe_key, String secret_key) {

        PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Initilializing Pubnub" + publish_key + subscribe_key + secret_key);
        __sharedInstance = new Pubnub(publish_key, subscribe_key, secret_key);
    }

    public static void setClientIdentifier(String clientIdentifier) {
        PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Set Client Identifier" + clientIdentifier);
        __sharedInstance.setUUID(clientIdentifier);
    }

    public static String getClientIdentifier() {
        PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Get Client Identifier");
        return __sharedInstance.UUID;
    }

    public static void subscribeOnChannel(String channel, ChannelSubscriptionCallback callback) {
        try {
            callback.retain_native();
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Subscribing on channel" + channel + " " + callback);

            try {
                __sharedInstance.subscribe(channel, callback);
            } catch (PubnubException pubnubException) {
                try {
                    PubnubError error = new PubnubError(PubnubError.PNERROBJ_INTERNAL_ERROR, pubnubException.toString());
                    callback.errorCallback(channel, error);
                    callback.removeFromSubscriptionCallbackList_native(channel);
                } catch (Exception e) {
                    PGLog.log(LOG_TAG, e.toString());
                }
            }
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }

    }

    public static void unsubscribeFromChannel(String channel, ChannelUnsubscriptionCallback callback) {
        try {
            callback.retain_native();

            try {
                __sharedInstance.unsubscribe(channel);
                callback.successCallback(channel, "Channel Unsubscribed");
            } catch (Exception e) {
                PubnubError error = PubnubError.PNERROBJ_INTERNAL_ERROR;
                callback.errorCallback(channel, error);
            }
            callback.removeFromUnsubscriptionCallbackList_native(channel);
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public static void sendMessage(String message, String channel, MessageProcessingCallback callback) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Send message on channel" + " " + channel + " " + message + " " + callback);

            callback.retain_native();
            __sharedInstance.publish(channel, message, callback);
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public static void sendJSONMessage(String message, String channel, MessageProcessingCallback callback) {
        try {
            JSONObject jsonMessage = new JSONObject(message);

            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Send json on channel" + " " + channel + " " + jsonMessage + " " + callback);

            callback.retain_native();
            __sharedInstance.publish(channel, jsonMessage, callback);
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public static void requestHistory(String channel, int count, boolean reverse, MessageHistoryProcessingCallback callback) {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " " + "Request History on channel" + " " + channel + " " + count + " " +reverse + " " + callback);

            callback.retain_native();
            __sharedInstance.history(channel, count, callback);
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }

    public static void shutdownPubnub() {
        try {
            PGLog.log(LOG_TAG, Thread.currentThread().getName() + " Shutting down Pubnub ");

            __sharedInstance.shutdown();

            __sharedInstance = null;
        }
        catch (Exception e) {
            PGLog.log(LOG_TAG, e.toString());
        }
    }
}
