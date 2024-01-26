package com.mob.mobpush.uniplugin;

import android.content.Context;
import android.os.Looper;
import android.util.Log;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.mob.MobSDK;
import com.mob.commons.MOBPUSH;
import com.mob.mobpush.uniplugin.impl.Consts;
import com.mob.mobpush.uniplugin.impl.LogUtils;
import com.mob.mobpush.uniplugin.impl.ObjectUtils;
import com.mob.pushsdk.MobPush;
import com.mob.pushsdk.MobPushCallback;
import com.mob.pushsdk.MobPushCustomMessage;
import com.mob.pushsdk.MobPushNotifyMessage;
import com.mob.pushsdk.MobPushReceiver;
import com.mob.tools.utils.HashonHelper;

import java.util.HashMap;
import java.util.Map;

import io.dcloud.feature.uniapp.annotation.UniJSMethod;
import io.dcloud.feature.uniapp.bridge.UniJSCallback;
import io.dcloud.feature.uniapp.common.UniModule;

public class MobPushModule extends UniModule {
    public MobPushModule() {
    }

    @UniJSMethod(uiThread = false)
    public void submitPolicyGrantResult(JSONObject grant) {
        try {
            LogUtils.log("submitPolicyGrantResult grant=" + grant);
            MobSDK.submitPolicyGrantResult(grant.getBooleanValue(Consts.Key.KEY_GRANT));
            MobSDK.setChannel(new MOBPUSH(), MobSDK.CHANNEL_UNIAPP);
        } catch (Throwable e) {
            LogUtils.log("submitPolicyGrantResult", e);
        }
    }

    @UniJSMethod(uiThread = false)
    public void getRegistrationID(final UniJSCallback uniJSCallback) {
        try {
            LogUtils.log("getRegistrationID");
            MobPush.getRegistrationId(new MobPushCallback<String>() {
                @Override
                public void onCallback(String s) {
                    LogUtils.log("rid=" + s);
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        HashMap<String, Object> resultMap = new HashMap<>();
                        resultMap.put(Consts.Key.KEY_SUCCESS, true);
                        resultMap.put(Consts.Key.KEY_RES, s);
                        resultMap.put(Consts.Key.KEY_ERROR, null);
                        uniJSCallback.invoke(resultMap);
                    }
                }
            });
        } catch (Throwable throwable) {
            LogUtils.log("getRegistrationID", throwable);
        }
    }

    @UniJSMethod(uiThread = false)
    public void addPushReceiver(final UniJSCallback uniJSCallback) {
        try {
            LogUtils.log("addPushReceiver callback not null? " + (ObjectUtils.nonNull(uniJSCallback)));
            if (ObjectUtils.isNull(uniJSCallback)) {
                return;
            }
            MobPush.addPushReceiver(new MobPushReceiver() {
                @Override
                public void onCustomMessageReceive(Context context, MobPushCustomMessage mobPushCustomMessage) {
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        Map<String, Object> result = new HashMap<>();
                        result.put(Consts.Key.KEY_ACTION, Consts.Value.ACTION_ON_CUSTOM_MESSAGE_RECEIVE);
                        result.put(Consts.Key.KEY_RES, HashonHelper.fromObject(mobPushCustomMessage));
                        result.put(Consts.Key.KEY_SUCCESS, true);
                        result.put(Consts.Key.KEY_ERROR, null);
                        uniJSCallback.invokeAndKeepAlive(result);
                    }
                }

                @Override
                public void onNotifyMessageReceive(Context context, MobPushNotifyMessage mobPushNotifyMessage) {
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        Map<String, Object> result = new HashMap<>();
                        result.put(Consts.Key.KEY_ACTION, Consts.Value.ACTION_ON_NOTIFY_MESSAGE_RECEIVE);
                        result.put(Consts.Key.KEY_RES, HashonHelper.fromObject(mobPushNotifyMessage));
                        result.put(Consts.Key.KEY_SUCCESS, true);
                        result.put(Consts.Key.KEY_ERROR, null);
                        uniJSCallback.invokeAndKeepAlive(result);
                    }
                }

                @Override
                public void onNotifyMessageOpenedReceive(Context context, MobPushNotifyMessage mobPushNotifyMessage) {
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        Map<String, Object> result = new HashMap<>();
                        result.put(Consts.Key.KEY_ACTION, Consts.Value.ACTION_ON_NOTIFY_MESSAGE_OPENED_RECEIVE);
                        result.put(Consts.Key.KEY_RES, HashonHelper.fromObject(mobPushNotifyMessage));
                        result.put(Consts.Key.KEY_SUCCESS, true);
                        result.put(Consts.Key.KEY_ERROR, null);
                        uniJSCallback.invokeAndKeepAlive(result);
                    }
                }

                @Override
                public void onTagsCallback(Context context, String[] strings, int operation, int errorCode) {
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        Map<String, Object> result = new HashMap<>();
                        result.put(Consts.Key.KEY_ACTION, Consts.Value.ACTION_ON_TAGS_CALLBACK);
                        result.put(Consts.Key.KEY_RES, strings);
                        if (errorCode == 0) {
                            result.put(Consts.Key.KEY_SUCCESS, true);
                        } else {
                            result.put(Consts.Key.KEY_SUCCESS, false);
                        }
                        result.put(Consts.Key.KEY_ERROR, errorCode);
                        result.put(Consts.Key.KEY_OPERATION, operation);
                        uniJSCallback.invokeAndKeepAlive(result);
                    }
                }

                @Override
                public void onAliasCallback(Context context, String s, int operation, int errorCode) {
                    if (ObjectUtils.nonNull(uniJSCallback)) {
                        Map<String, Object> result = new HashMap<>();
                        result.put(Consts.Key.KEY_ACTION, Consts.Value.ACTION_ON_ALIAS_CALLBACK);
                        result.put(Consts.Key.KEY_RES, s);
                        if (errorCode == 0) {
                            result.put(Consts.Key.KEY_SUCCESS, true);
                        } else {
                            result.put(Consts.Key.KEY_SUCCESS, false);
                        }
                        result.put(Consts.Key.KEY_ERROR, errorCode);
                        result.put(Consts.Key.KEY_OPERATION, operation);
                        uniJSCallback.invokeAndKeepAlive(result);
                    }
                }
            });
        } catch (Throwable throwable) {
            LogUtils.log("addPushReceiver callback not null? ", throwable);
        }
    }

    /**
     * 关闭推送功能
     */
    @UniJSMethod(uiThread = false)
    public void stopPush() {
        try {
            LogUtils.log("stopPush");
            MobPush.stopPush();
        } catch (Throwable throwable) {
            LogUtils.log("stopPush", throwable);
        }

    }

    /**
     * 重启推送功能
     */
    @UniJSMethod(uiThread = false)
    public void restartPush() {
        try {
            LogUtils.log("restartPush");
            MobPush.restartPush();
        } catch (Throwable throwable) {
            LogUtils.log("restartPush", throwable);
        }

    }

    /**
     * 获取推送是否关闭
     *
     * @param callback
     */
    @UniJSMethod(uiThread = false)
    public void isPushStopped(final UniJSCallback callback) {
        try {
            LogUtils.log("isPushStopped");
            MobPush.isPushStopped(new MobPushCallback<Boolean>() {
                @Override
                public void onCallback(Boolean aBoolean) {
                    if (ObjectUtils.nonNull(callback)) {
                        HashMap<String, Object> params = new HashMap<>();
                        params.put(Consts.Key.KEY_SUCCESS, true);
                        params.put(Consts.Key.KEY_RES, aBoolean);
                        params.put(Consts.Key.KEY_ERROR, null);
                        callback.invoke(params);
                    }
                }
            });
        } catch (Throwable throwable) {
            LogUtils.log("isPushStopped", throwable);
        }

    }

    /**
     * 设置别名
     */
    @UniJSMethod(uiThread = false)
    public void setAlias(JSONObject alias) {
        try {
            LogUtils.log("setAlias");
            MobPush.setAlias(alias.getString(Consts.Key.KEY_ALIAS));
        } catch (Throwable throwable) {
            LogUtils.log("setAlias", throwable);
        }

    }

    /**
     * 获取别名
     */
    @UniJSMethod(uiThread = false)
    public void getAlias() {
        try {
            LogUtils.log("getAlias");
            MobPush.getAlias();
        } catch (Throwable throwable) {
            LogUtils.log("getAlias", throwable);
        }

    }

    /**
     * 删除别名
     */
    @UniJSMethod(uiThread = false)
    public void deleteAlias() {
        try {
            LogUtils.log("deleteAlias");
            MobPush.deleteAlias();
        } catch (Throwable throwable) {
            LogUtils.log("deleteAlias", throwable);
        }

    }

    /**
     * 添加标签
     */
    @UniJSMethod(uiThread = false)
    public void addTags(JSONObject options) {
        try {
            LogUtils.log("addTags");
            if (ObjectUtils.isNull(options) || options.isEmpty()) {
                LogUtils.log("options invalid!");
            }
            JSONArray tags = options.getJSONArray(Consts.Key.KEY_TAGS);
            MobPush.addTags(tags.toArray(new String[]{}));
        } catch (Throwable throwable) {
            LogUtils.log("addTags", throwable);
        }

    }

    /**
     * 获取标签
     */
    @UniJSMethod(uiThread = false)
    public void getTags() {
        try {
            LogUtils.log("getTags");
            MobPush.getTags();
        } catch (Throwable throwable) {
            LogUtils.log("getTags", throwable);
        }

    }

    /**
     * 删除标签
     */
    @UniJSMethod(uiThread = false)
    public void deleteTags(JSONObject options) {
        try {
            LogUtils.log("deleteTags");
            if (ObjectUtils.isNull(options) || options.isEmpty()) {
                LogUtils.log("options invalid!");
            }
            JSONArray tags = options.getJSONArray(Consts.Key.KEY_TAGS);
            LogUtils.log(tags.toJSONString());
            MobPush.deleteTags(tags.toArray(new String[]{}));
        } catch (Throwable throwable) {
            LogUtils.log("deleteTags", throwable);
        }
    }

    /**
     * 清除标签
     */
    @UniJSMethod(uiThread = false)
    public void cleanAllTags() {
        try {
            LogUtils.log("cleanAllTags");
            MobPush.cleanTags();
        } catch (Throwable throwable) {
            LogUtils.log("cleanAllTags", throwable);
        }
    }

    /**
     * 设置角标状态
     */
    @UniJSMethod(uiThread = false)
    public void setShowBadge(JSONObject showBadge) {
        try {
            boolean showBadgeBooleanValue = showBadge.getBooleanValue(Consts.Key.KEY_SHOWBADGE);
            LogUtils.log("setShowBadge:" + showBadgeBooleanValue);
            MobPush.setShowBadge(showBadgeBooleanValue);
        } catch (Throwable T) {
            LogUtils.log("setShowBadge", T);
        }
    }

    /**
     * 获取角标状态
     */
    @UniJSMethod(uiThread = false)
    public void getShowBadge(final UniJSCallback callback) {
        try {
            LogUtils.log("getShowBadge");
            if (ObjectUtils.nonNull(callback)) {
                boolean showBadge = MobPush.getShowBadge();
                HashMap<String, Object> resultMap = new HashMap<>();
                resultMap.put(Consts.Key.KEY_SUCCESS, true);
                resultMap.put(Consts.Key.KEY_RES, showBadge);
                resultMap.put(Consts.Key.KEY_ERROR, null);
                callback.invoke(resultMap);
            }
        } catch (Throwable throwable) {
            LogUtils.log("getShowBadge", throwable);
        }
    }


    @UniJSMethod(uiThread = false)
    public void setSilenceTime(JSONObject SilenceTime) {
        try {
            int startHour = SilenceTime.getInteger(Consts.Key.KEY_STARTHOUR);
            int startMinute = SilenceTime.getInteger(Consts.Key.KEY_STARTMINUTE);
            int endHour = SilenceTime.getInteger(Consts.Key.KEY_ENDHOUR);
            int endMinute = SilenceTime.getInteger(Consts.Key.KEY_ENDMINUTE);
            LogUtils.log(String.format("setSilenceTime startHour=%s,startMinute=%s,endHour=%s,endMinute=%s", startHour, startMinute, endHour, endMinute));
            MobPush.setSilenceTime(startHour, startMinute, endHour, endMinute);
        } catch (Throwable throwable) {
            LogUtils.log("setSilenceTime", throwable);
        }
    }

    /**
     * 设置debug日志
     */
    @UniJSMethod
    public void enableLog(JSONObject enable) {
        LogUtils.enableDebug = enable.getBooleanValue(Consts.Key.KEY_ENABLELOG);
    }
}
