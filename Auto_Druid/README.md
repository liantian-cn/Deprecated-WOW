# Auto_Druid
A Druid Routines For WOW

德鲁伊自动脚本。

## 更新

* 2017.8.20 - 新增猫咪输出




## 食用指南：

### 基本

1. 下载最新版本：[Auto_Druid-master.zip](https://github.com/liantian-cn/Auto_Druid/archive/master.zip)
2. 将其中的Auto_Druid目录保存到插件目录:`Wow/interface/addons/`
3. 下载[oLUA-64.exe](https://static.liantian.me/download/ahRifnN0YXRpYy1saWFudGlhbi1tZXIVCxIIRG9jdW1lbnQYgICAgIDkkQoM/oLUA-64.exe)
4. 启动游戏。
5. 以管理员身份运行oLUA-64
5. 选择wow序列号，只开一个wow窗口时为0，按回车。
6. 游戏内可以使用以下宏，可配合任何已有宏使用。


### 悬浮窗
![20170617234057.png](https://static.liantian.me/download/ahRifnN0YXRpYy1saWFudGlhbi1tZXIVCxIIRG9jdW1lbnQYgICAgPiWlQoM/20170617234057.png)![20170617234049.png](https://static.liantian.me/download/ahRifnN0YXRpYy1saWFudGlhbi1tZXIVCxIIRG9jdW1lbnQYgICAgO2xgwoM/20170617234049.png)

* 爆发：是否使用`狂暴`、`化身`等技能。
* AOE：星落位置，在鼠标位置，还是玩家脚下。
* 数字：根据敌人数量的策略，只有平衡支持。
* 可以通过点击文字进行切换，也可以通过宏。
* 中间区域可以拖动


## 专精简介及宏

#### 通用

* `/run Auto_Druid_ADD_ENEMY_NUM()` ： 增加目标数量。
* `/run Auto_Druid_CUT_ENEMY_NUM()` ： 减少目标数量。
* `/run Auto_Druid_SWITCH_BURST()` ： 切换爆发状态。
* `/run Auto_Druid_SWITCH_AOE()` ： 切换AOE位置。



#### 平衡

* 支援搭配所有核心橙：`橙头`、`护腕`、`肩膀`、`化身戒`、`魂戒`。
* 支援所有天赋。
* 输出参考simc模型。
* 1、2、3-5目标分别不同的输出策略。
* 使用`/run Simc_Moonkin();`进行一键输出。

#### 守护

* 不支援天赋主动技能。
* 免伤技能仅使用：`狂暴回复`、`铁鬃`。
* 输出策略，从上到下优先级：
	* `星河守护者`触发时使用`月火`。
	* 没有`月火`或DOT小于4.8秒时，补`月火`。
	* `痛击`可用时使用`痛击`。
	* `裂伤`可用时使用`裂伤`。
	* 使用`横扫`
* 防御策略：
	* 怒气 > 70使用`铁鬃`。
	* 血量低于40%，使用`狂暴回复`。
	* 前5秒承受伤害大于生命值50%时，使用`狂暴回复`。
* 使用`/run Simc_Bear();`进行一键输出。

#### 野性

* 暂仅支持单目标输出，不支持面板的目标数量控制。
* 后续添加AOE功能。
* 天赋：
	* 15级天赋选： `血之气息`
	* 75级天赋选： `野蛮咆哮`
	* 90级天赋选： `锯齿创伤`
	* 100级天赋选：`血腥爪击`
* 兼容橙，按推荐顺序排列：
	* `猫眼石玺戒`
	* `大德鲁伊之魂`
	* `巨兽头饰`
	* `荒野变形者之爪`
* 使用`/run Simc_Cat();`进行一键输出。


LICENSE: Noncommercial
版权：不得用于商业。


最近支持wow版本:7.2.5.24742