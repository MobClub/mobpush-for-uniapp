package com.mob.mobpush.uniplugin.impl;

public class Consts {
    public static final class Key {
        /**
         * 回调类型
         */
        public static final String KEY_ACTION = "action";
        public static final String KEY_RES = "res";
        public static final String KEY_SUCCESS = "success";
        public static final String KEY_ERROR = "error";
        public static final String KEY_OPERATION = "operation";
        public static final String KEY_TAGS = "tags";
        public static final String KEY_ALIAS = "alias";
        public static final String KEY_GRANT = "grant";
        public static final String KEY_ENABLELOG = "enableLog";
        public static final String KEY_STARTHOUR = "startHour";
        public static final String KEY_STARTMINUTE = "startMinute";
        public static final String KEY_ENDHOUR = "endHour";
        public static final String KEY_ENDMINUTE = "endMinute";
        public static final String KEY_SHOWBADGE = "showBadge";

    }

    public static final class Value {
        public static final String ACTION_ON_CUSTOM_MESSAGE_RECEIVE = "onCustomMessageReceive";
        public static final String ACTION_ON_NOTIFY_MESSAGE_RECEIVE = "onNotifyMessageReceive";
        public static final String ACTION_ON_NOTIFY_MESSAGE_OPENED_RECEIVE = "onNotifyMessageOpenedReceive";
        public static final String ACTION_ON_TAGS_CALLBACK = "onTagsCallback";
        public static final String ACTION_ON_ALIAS_CALLBACK = "onAliasCallback";
    }
}
