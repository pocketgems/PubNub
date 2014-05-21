package com.pubnub.api;

import java.util.UUID;

/**
 * Pubnub object facilitates querying channels for messages and listening on
 * channels for presence/message events
 *
 * @author Pubnub
 *
 */

public class Pubnub extends PubnubCore {
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

    protected PubnubError generateError(String errorMessage) {
        return new PubnubError(PubnubError.PNERROBJ_INTERNAL_ERROR, errorMessage);
    }
}
