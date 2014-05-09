package com.pocketgems.pgengine.pubnub;

import java.lang.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Ravi on 3/28/14.
 */

public class PubnubUtility {

    public static String JSONString(Object obj) {
        String jsonString = null;
        if (obj instanceof JSONObject) {
            jsonString = obj.toString();
        }
        else if (obj instanceof JSONArray) {
            jsonString = obj.toString();
        }
        else if (obj instanceof String) {
            jsonString = "\""+obj+"\"";
        }
        else {
            jsonString = obj.toString();
        }
        return jsonString;
    }
}