package com.pocketgems.pgengine.pubnub;

import com.pubnub.api.*;

import org.json.JSONObject;

/**
 * Pubnub object that implements the required static bridge methods for PG support
 *
 * @author Orlando
 *
 */
public class PGPubnub extends Pubnub {
    private static Logger log = new Logger(PGPubnub.class);

    /**
     * @param publish_key
     * @param subscribe_key
     * @param secret_key
     */
    public PGPubnub(String publish_key, String subscribe_key, String secret_key) {
        super(publish_key, subscribe_key, secret_key);
    }

    // Static Methods

    static PGPubnub __sharedInstance = null;
    public static void initialializePubnub(String publish_key, String subscribe_key, String secret_key) {
        log.verbose("Initilializing Pubnub: " + publish_key + " " + subscribe_key + " " + secret_key);
        __sharedInstance = new PGPubnub(publish_key, subscribe_key, secret_key);
    }

    public static void setClientIdentifier(String clientIdentifier) {
        log.verbose("Setting Client Identifier: " + clientIdentifier);
        __sharedInstance.setUUID(clientIdentifier);
    }

    public static String getClientIdentifier() {
        log.verbose("Requesting client identifier");
        return __sharedInstance.UUID;
    }

    public static void subscribeOnChannel(String channel, ChannelSubscriptionCallback callback) {
        try {
            callback.retain_native();
            log.verbose("Subscribing on channel: " + channel + " " + callback);

            try {
                __sharedInstance.subscribe(channel, callback);
            } catch (PubnubException pubnubException) {
                try {
                    PubnubError error = __sharedInstance.generateError(pubnubException.toString());
                    callback.errorCallback(channel, error);
                    callback.removeFromSubscriptionCallbackList_native(channel);
                } catch (Exception e) {
                    log.error(e.toString());
                }
            }
        }
        catch (Exception e) {
            log.error(e.toString());
        }

    }

    public static void unsubscribeFromChannel(String channel, ChannelUnsubscriptionCallback callback) {
        try {
            callback.retain_native();

            try {
                __sharedInstance.unsubscribe(channel);
                callback.successCallback(channel, "Channel Unsubscribed");
            } catch (Exception e) {
                PubnubError error = __sharedInstance.generateError(e.toString());
                callback.errorCallback(channel, error);
            }
            callback.removeFromUnsubscriptionCallbackList_native(channel);
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public static void sendMessage(String message, String channel, MessageProcessingCallback callback) {
        try {
            log.verbose("Sending message on channel" + " " + channel + " " + message + " " + callback);
            callback.retain_native();
            __sharedInstance.publish(channel, message, callback);
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public static void sendJSONMessage(String message, String channel, MessageProcessingCallback callback) {
        try {
            JSONObject jsonMessage = new JSONObject(message);
            log.verbose("Sending json message on channel" + " " + channel + " " + jsonMessage + " " + callback);
            callback.retain_native();
            __sharedInstance.publish(channel, jsonMessage, callback);
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public static void requestHistory(String channel, int count, boolean reverse, MessageHistoryProcessingCallback callback) {
        try {
            log.verbose("Requesting history on channel" + " " + channel + " " + count + " " +reverse + " " + callback);
            callback.retain_native();
            __sharedInstance.history(channel, count, callback);
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }

    public static void shutdownPubnub() {
        try {
            log.verbose("Shutting down Pubnub ");
            __sharedInstance.shutdown();
            __sharedInstance = null;
        }
        catch (Exception e) {
            log.error(e.toString());
        }
    }
}
