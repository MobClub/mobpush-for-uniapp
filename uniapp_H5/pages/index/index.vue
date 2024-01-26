<!-- 本示例未包含完整css，获取外链css请参考上文，在hello uni-app项目中查看 -->
<template>
	<view>
		<view class="uni-padding-wrap uni-common-mt">
			<view>
				<scroll-view :scroll-top="scrollTop" scroll-y="true" class="scroll-Y" @scrolltoupper="upper"
					@scrolltolower="lower" @scroll="scroll">
					<button v-on:click="enableLog">setEnableLog</button>
					<button v-on:click="setAPNsForProduction">SetProduction</button>
					<button v-on:click="submitPolicyGrantResult">submitPolicyGrantResult</button>
					<button v-on:click="setAPNsNotification">setAPNsNotification</button>
					<button v-on:click="setAPNsShowForegroundType">setAPNsShowForegroundType</button>
					<button v-on:click="getRegistrationID">getRegistrationID</button>
					<button v-on:click="addPushReceiver">addPushReceiver</button>
					<button v-on:click="clearPushReceivers">clearPushReceivers</button>
					<button v-on:click="stopPush">stopPush</button>
					<button v-on:click="restartPush">restartPush</button>
					<button v-on:click="isPushStopped">isPushStopped</button>
					<input placeholder="请输入别名:" v-model.trim="alias" />
					<button v-on:click="setAlias(alias)">setAlias</button>
					<button v-on:click="deleteAlias">deleteAlias</button>
					<button v-on:click="getAlias">getAlias</button>
					<input placeholder='请输入一个标签,以";"分割:' v-model.trim="tagsStr" />
					<button v-on:click="addTags(tagsStr)">addTags</button>
					<button v-on:click="deleteTags(tagsStr)">deleteTags</button>
					<button v-on:click="getTags">getTags</button>
					<button v-on:click="cleanAllTags">cleanAllTags</button>
					<button v-on:click="setShowBadge">setShowBadge</button>
					<button v-on:click="getShowBadge">getShowBadge</button>
					<button v-on:click="getShowBadge">getShowBadge</button>
					<button v-on:click="clearBadge">clearBadge</button>
					<button v-on:click="setSilenceTime(startHour,startMinute,endHour,endMinute)">setSilenceTime</button>
				</scroll-view>
			</view>


		</view>
	</view>
</template>


<script>
	export default {

		created: function() {
			this.mobPushUniPlugin = uni.requireNativePlugin('mob-push')
		},
		data() {
			return {
				title: "mobpush 测试demo",
				alias: "", //推送别名
				tagsStr: "",
				startHour: 0,
				startMinute: 0,
				endHour: 0,
				endMinute: 0

			}
		},

		methods: {

			toast: function(msg) {
				uni.showToast({
					title: msg,
					icon: 'none',
					duration: 5000
				})
			},
			// 设置SDK环境
			setAPNsForProduction: function() {
				if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.setAPNsForProduction({
						'isPro': true
					})
				}
			},
			//同意隐私协议接口
			submitPolicyGrantResult: function() {
				this.mobPushUniPlugin.submitPolicyGrantResult({
					"grant": true
				})
			},
			setAPNsNotification: function() {
				if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.setAPNsNotification({
						'type': 7
					})
				}
			},
			/**
			 * app 在前台时设置消息显示类型
			 * 无显示 0
			 * 角标提醒 1
			 * 声音提醒 2
			 * 弹框提醒 4
			 * 全部 7
			 * */
			setAPNsShowForegroundType: function() {
				if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.setAPNsShowForegroundType({
						'type': 7
					})
				}
			},
			//获取推送rid
			getRegistrationID: function() {
				this.mobPushUniPlugin.getRegistrationID((result) => {
					this.toast(JSON.stringify(result))
				})
			},
			//推送回调
			addPushReceiver: function() {
				this.mobPushUniPlugin.addPushReceiver((result) => {
					this.toast(JSON.stringify(result))
				})
			},
			// 清除推送回调
			clearPushReceivers: function() {
				if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.clearPushReceivers()
				}
			},
			//关闭推送功能
			stopPush: function() {
				this.mobPushUniPlugin.stopPush()
			},
			//重启推送功能
			restartPush: function() {
				this.mobPushUniPlugin.restartPush()
			},
			//获取推送是否关闭
			isPushStopped: function() {
				this.mobPushUniPlugin.isPushStopped((result) => {
					this.toast(JSON.stringify(result))
				})
			},
			//设置别名
			setAlias: function(alias) {
				if (alias == '') {
					this.toast("请输入别名！")
					return
				}
				this.mobPushUniPlugin.setAlias({
					"alias": alias
				})
			},

			//获取别名
			getAlias: function() {
				this.mobPushUniPlugin.getAlias()
			},
			//删除别名
			deleteAlias: function() {
				this.mobPushUniPlugin.deleteAlias()
			},
			//添加标签
			addTags: function(tagsStr) {
				if (tagsStr == '') {
					this.toast('请输入标签，以";"隔开！')
					return
				}
				var tags = tagsStr.split(';')
				if (tags.length <= 0) {
					this.toast('请输入标签，以";"隔开！')
					return
				}
				console.error(tags)
				this.mobPushUniPlugin.addTags({
					"tags": tags
				})
			},
			//获取标签
			getTags: function() {
				this.mobPushUniPlugin.getTags()
			},
			//删除标签
			deleteTags: function(tagsStr) {
				if (tagsStr == '') {
					this.toast('请输入标签，以";"隔开！')
					return
				}
				var tags = tagsStr.split(';')
				if (tags.length <= 0) {
					this.toast('请输入标签，以";"隔开！')
					return
				}
				console.error(tags)
				this.mobPushUniPlugin.deleteTags({
					"tags": tags
				})
			},
			//清楚标签
			cleanAllTags: function() {
				this.mobPushUniPlugin.cleanAllTags()
			},

			setSilenceTime: function(startHour, startMinute, endHour, endMinute) {
				this.mobPushUniPlugin.setSilenceTime({
					"startHour": startHour,
					"startMinute": startMinute,
					"endHour": endHour,
					"endMinute": endMinute
				})
			},
			//设置debug日志
			enableLog: function() {
				this.mobPushUniPlugin.enableLog({
					"enableLog": true
				})
			},
			//设置角标状态
			setShowBadge: function() {
				if (uni.getSystemInfoSync().platform == 'android') {
					this.mobPushUniPlugin.setShowBadge({
						"showBadge": true
					})
				} else if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.setBadge({
						'badge': 10
					})
				}
			},
			//获取角标状态
			getShowBadge: function() {
				if (uni.getSystemInfoSync().platform == 'android') {
					this.mobPushUniPlugin.getShowBadge((result) => {
						this.toast(JSON.stringify(result))
					})
				} else if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.getBadge ((result) => {
						this.toast(JSON.stringify(result))
					})
				}
			},
			// 清空角标
			clearBadge: function() {
				if (uni.getSystemInfoSync().platform == 'ios') {
					this.mobPushUniPlugin.clearBadge()
				}
			}
		}
	}
</script>


<style>
	.scroll-Y {}

	.scroll-view-item {
		height: 300rpx;
		line-height: 300rpx;
		text-align: center;
		font-size: 36rpx;
	}
</style>
