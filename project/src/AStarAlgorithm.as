package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	[SWF(width="900", height="600", frameRate="60", backgroundColor="#FFFFFF")]
	public class AStarAlgorithm extends Sprite
	{
		private var w:uint;//横向节点数
		private var h:uint;//纵向节点数
		private var wh:uint;//节点的宽与高
		private var goo:Number;//控制地图中节点是否可通过的比率，数值在0.1-0.5之间，数值越小，地图上障碍越多
		private var map:Sprite;//地图容器
		private var mapArr:Array=new Array;//地图信息数组
		private var roadMen:MovieClip;//寻路人
		private var roadList:Array;//寻路返回的路径
		private var roadTimer:Timer;//计数器
		private var timer_i:uint=0;//配合计数器实现寻路人动画（很郁闷，不知如何在Timer事件中传递参数，只能这么解决）
		public var roadinf:TextField;
		public var roadLen:TextField;
		public function AStarAlgorithm()
		{
			initTF();
			init();
			sort();
		}
		
		private function sort():void
		{
			var a_array:Array = new Array(21, 545, 154, 15, 845, 45, 568, 784);
			function swap( i:int, j:int ):void
			{
				var a:int = a_array[i];
				a_array[i] = a_array[j];
				a_array[j] = a;
			}
			var len:Number = a_array.length;
			for (var m:Number = 0; m<20; m++)
			{
				for (var i:Number = 0; i<len-1; i++)
				{
					for (var j:Number = 0; j<len-1; j++)
					{
						swap(j, j+1);
					}
				}
				trace( "第", m, "行： ", a_array );
			}
		}
		private function initTF():void
		{
			roadinf = new TextField();
			roadLen = new TextField();
			addChild(roadLen);
			addChild(roadinf);
			
			roadinf.y = roadLen.y = 567.5;
			roadinf.width = roadLen.width = 104;
			roadinf.height = roadLen.height = 18.5;
			
			roadLen.x = 140;
			roadinf.x = 20;
		}
		//初始化－－－－－－－－－－－－－－－－－－－－－》
		private function init():void
		{
			w=98;//地横向节点
			h=60;//地图竖向节点
			wh=9;//节点大小
			goo=0.3;//地图障碍几率
			createMaps();//生成随机地图
			roadMens();//生成寻路人
			roadTimer=new Timer(80,0);//定义计时器以完成寻路人行走动画
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDowns);//空格按键事件
		}//End fun init
		
		//当用户点击地图时开始寻路－－－－－－－－－－－－－》
		private function mapMousedown(evt:MouseEvent):void
		{
			var endX:int = Math.floor((mouseX-map.x)/ wh);//将鼠标点击位置转化为节点索引值
			var endY:int = Math.floor((mouseY-map.y)/ wh);//将鼠标点击位置转化为节点索引值
			var endPoint:MovieClip = mapArr[ endY ][ endX ];//从地图中取出鼠标点击的节点作为寻路终点
			//如果目的地是可通过的则开始寻路
			if (endPoint.go == 0)
			{
				//每次寻路开始前将上次的路径清空
				if (roadList)
				{
					for each (var mc:MovieClip in roadList)
					{
						mc.alpha=1;
					}
					roadList=[];
				}//End if
				roadTimer.stop();//停止走路
				//动态取得寻路人当前位置的索引，并更新
				roadMen.px=Math.floor(roadMen.x/wh);
				roadMen.py=Math.floor(roadMen.y/wh);
				var _AStar:AStar=new AStar();//生成寻路实例
				
				var oldTimes:int = getTimer();//记录发送寻路方法时间
				roadList=_AStar.searchRoad(roadMen,endPoint,mapArr);//调用寻路方法（寻路人，目的地，地图信息）
				var times:int = getTimer() - oldTimes;//寻路方法执行完毕计算寻路花费时间
				if ( roadList.length>0 )
				{
					roadinf.htmlText="本次寻路<FONT color='#00ff00'>"+times.toString()+"</FONT> 毫秒";
					roadLen.htmlText="路径长度：<FONT color='#00ff00'>"+roadList.length.toString()+"</FONT>";//路径长度
					MC_play(roadList);//让寻路人行走
				}
				else
				{
					roadinf.htmlText="对不起，无路可走";
				}//End if
			}//End if
		}//End fun
		
		//寻路人行走－－－－－－－－－－－－－－－－－－－－－－》
		private function MC_play(roadList:Array):void
		{
			roadList.reverse();//倒转数组
			roadTimer.stop();
			timer_i=0;
			roadTimer.addEventListener(TimerEvent.TIMER,goMap);
			roadTimer.start();
			for each (var mc:MovieClip in roadList)
			{
				mc.alpha=0.3;
			}//End if
		}//End fun
		//每隔一定时间行走一格－－－－－－－－－－－－－－－－》
		private function goMap( evt:TimerEvent ):void
		{
			var tmpMC:MovieClip=roadList[timer_i];
			roadMen.x=tmpMC.x;
			roadMen.y=tmpMC.y;
			tmpMC.alpha=1;//经过路径后消除其标识状态
			timer_i++;
			//达到终点行走停止
			if ( timer_i>=roadList.length )
			{
				roadTimer.stop();
			}//End if
		}//End fun
		//生成地图并存储信息－－－－－－－－－－－－－－－－－》
		private function createMaps():void
		{
			map=new Sprite  ;//地图容器
			map.x=wh;
			map.y=wh;
			addChild(map);
			map.addEventListener(MouseEvent.MOUSE_DOWN,mapMousedown);//鼠标点击地图事件
			for (var y:uint=0; y < h; y++)
			{
				mapArr.push(new Array  );//建立二维数组存储地图信息
				for (var x:uint=0; x < w; x++)
				{
					var mapPoint:uint=Math.round(Math.random() - goo);//(0可通过为灰色或者1不可通过为黑色)
					var point:MovieClip=drawRect(mapPoint);//画出节点
					mapArr[y].push(point);//将节点加入地图数组中
					
					point.px=x;//当前节点横向索引位置
					point.py=y;//当前节点纵向索引位置
					point.go=mapPoint;//当前节点是否可通过
					point.x=x * wh;//当前节点的x位置
					point.y=y * wh;//当前节点的y位置
					
					map.addChild(mapArr[y][x]);//将节点显示到地图容器中
				}//End for x
			}//End for y
		}//End fun 
		//空格键重生地图－－－－－－－－－－－－－－－－－－--》
		private function keyDowns(evt:KeyboardEvent):void
		{
			var _key:int = evt.keyCode;
			if ( _key == Keyboard.SPACE )
			{
				removeChild( map );
				mapArr=[];
				createMaps();
				roadMens();//生成寻路人
				roadTimer.stop();
			}//End if
		}//End if
		
		//根据传入的随机数画出不同的节点（即可通过/不可通过/寻路人）－－－》
		private function drawRect(mapPoint:uint):MovieClip
		{
			var _tmp:MovieClip=new MovieClip;
			var color:uint;
			switch (mapPoint)
			{
				case 0 :
					color=0x999999;//可通过为灰色
					break;
				case 1 :
					color=0x000000;//不可通过为黑色
					break;
				default :
					color=0xFF0000;//否则为寻路人
			}//End switch
			_tmp.graphics.beginFill(color);
			_tmp.graphics.lineStyle(0.2,0xFFFFFF);
			_tmp.graphics.drawRect(0,0,wh,wh);
			_tmp.graphics.endFill();
			return _tmp;
		}//End fun drawRect
		
		//生成寻路人－－－－－－－－－－－－－－－－－－－－－－－－－》
		private function roadMens():void
		{
			roadMen=drawRect(2);
			//让寻路人随机出现在地图上并设置寻路人的横纵向索引位置----->
			var _tmpx:uint=Math.round(Math.random() * (w-1));
			var _tmpy:uint=Math.round(Math.random() * (h-1));
			roadMen.px =_tmpx;//记录所在位置索引值
			roadMen.py=_tmpy;
			roadMen.x=_tmpx * wh;
			roadMen.y=_tmpy * wh;
			mapArr[_tmpy][_tmpx].go=0;//让寻路人出现的地图点变为可通过
			map.addChild(roadMen);
		}
	}
}