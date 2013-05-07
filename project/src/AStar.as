package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	public class AStar extends Sprite {
		private var startPoint:MovieClip;//寻路起点
		private var endPoint:MovieClip;//要到达的目的地
		private var mapArr:Array;//地图信息
		private var w:uint;//地图的横向节点数
		private var h:uint;//地图的纵向节点数
		private var openList:Array=new Array();//开启列表
		private var closeList:Array=new Array();//关闭列表
		private var roadArr:Array=new Array();//返回的路径
		private var isPath:Boolean;//是否找到路径
		private var isSearch:Boolean;//寻路状态,即是否正在寻路
		public function AStar() {
		}//End Fun
		//对外的寻路接口
		public function searchRoad(start:MovieClip,end:MovieClip,map:Array):Array
		{
			startPoint=start;//获得寻路起点
			endPoint=end;//获得要到达的目的地
			mapArr=map;//获得地图信息
			w=mapArr[0].length-1;//获得地图横向的节点数
			h=mapArr.length-1;//获得地图纵向的节点数
			openList.push(startPoint);//将起点加入开启列表
			while (true) {
				if (openList.length<1) {//无路可走
					//trace("无路可走");
					return roadArr;
					break;
				}
				var thisPoint:MovieClip=openList.splice(getMinF(),1)[0];//每次取出开启列表中的第一个节点
				if (thisPoint==endPoint) {//找到路径
					//trace("找到路径");
					//从终点开始往回找父节点，以生成路径列表，直到父节点为起始点
					while (thisPoint.father != startPoint.father) {
						roadArr.push(thisPoint);
						thisPoint=thisPoint.father;
					}
					return roadArr;//返回路径列表
					break;
				}
				closeList.push(thisPoint);//把当前节点加入关闭列表
				addAroundPoint(thisPoint);//开始检查当前节点四周的节点
				/*openList.sortOn(["F"]);//对开启列表中的节点按F值排序
				//（超级郁闷，原来本方法均把F值当成字符串比较了，位数相同的数值可比，不然20会比100大）
				for each (var mc:MovieClip in openList) {
				trace(mc.F);
				}
				trace("=============");*/
			}//End while
			return roadArr;
		}//End Fun
		
		//检查当前节点四周的八个节点，可通过并不在关闭及开启列表中的节点加入至开启列表
		private function addAroundPoint(thisPoint:MovieClip):void {
			var thisPx:uint=thisPoint.px;//当前节点横向索引
			var thisPy:uint=thisPoint.py;//当前节点纵向索引
			//添加左右两个直点的同时过滤四个角点，以提高速度。
			//即如果左边点不存在或不可通过则左上左下两角点就不需检查，右边点不存在或不可通过则右上右下两角点不需检查
			//后面添加四个为角点，角点的判断为，自身可通过&&它相邻的两个当前点的直点都可通过
			if (thisPx>0 && mapArr[thisPy][thisPx - 1].go==0 ) {//加入左边点
				if (!inArr(mapArr[thisPy][thisPx - 1],closeList)) {//是否在关闭列表中
					if (!inArr(mapArr[thisPy][thisPx - 1],openList)) {//是否在开启列表中
						setGHF(mapArr[thisPy][thisPx - 1],thisPoint,10);//计算GHF值
						openList.push(mapArr[thisPy][thisPx - 1]);//加入节点
					} else {
						checkG(mapArr[thisPy][thisPx-1],thisPoint);//检查G值
					}//End if
				}//End if
				//加入左上点
				if (thisPy>0 && mapArr[thisPy-1][thisPx - 1].go==0&& mapArr[thisPy - 1][thisPx].go==0) {
					if (!inArr(mapArr[thisPy-1][thisPx - 1],closeList) && !inArr(mapArr[thisPy-1][thisPx - 1],openList)) {
						setGHF(mapArr[thisPy - 1][thisPx-1],thisPoint,14);//计算GHF值
						openList.push(mapArr[thisPy-1][thisPx - 1]);//加入节点
					}//End if
				}//End if
				//加入左下点
				if (thisPy<h && mapArr[thisPy+1][thisPx - 1].go==0  && mapArr[thisPy + 1][thisPx].go==0) {
					if (!inArr(mapArr[thisPy+1][thisPx - 1],closeList) && !inArr(mapArr[thisPy+1][thisPx - 1],openList)) {
						setGHF(mapArr[thisPy + 1][thisPx-1],thisPoint,14);//计算GHF值
						openList.push(mapArr[thisPy+1][thisPx - 1]);//加入节点
					}//End if
				}//End if
			}//End if
			if (thisPx<w && mapArr[thisPy][thisPx + 1].go==0) {//加入右边点
				if (!inArr(mapArr[thisPy][thisPx + 1],closeList)) {//是否在关闭列表中
					if (!inArr(mapArr[thisPy][thisPx + 1],openList)) {//是否在开启列表中
						setGHF(mapArr[thisPy][thisPx + 1],thisPoint,10);//计算GHF值
						openList.push(mapArr[thisPy][thisPx + 1]);//加入节点
					} else {
						checkG(mapArr[thisPy][thisPx + 1],thisPoint);//检查G值
					}//End if
				}//End if
				//加入右上点
				if (thisPy>0 && mapArr[thisPy-1][thisPx +1].go==0  && mapArr[thisPy - 1][thisPx].go==0) {
					if (!inArr(mapArr[thisPy-1][thisPx + 1],closeList) && !inArr(mapArr[thisPy-1][thisPx + 1],openList)) {
						setGHF(mapArr[thisPy - 1][thisPx+1],thisPoint,14);//计算GHF值
						openList.push(mapArr[thisPy-1][thisPx + 1]);//加入节点
					}//End if
				}//End if
				//加入右下点
				if (thisPy<h && mapArr[thisPy+1][thisPx + 1].go==0 && mapArr[thisPy + 1][thisPx].go==0) {
					if (!inArr(mapArr[thisPy+1][thisPx+ 1],closeList) && !inArr(mapArr[thisPy+1][thisPx + 1],openList)) {
						setGHF(mapArr[thisPy + 1][thisPx+1],thisPoint,14);//计算GHF值
						openList.push(mapArr[thisPy+1][thisPx + 1]);//加入节点
					}//End if
				}//End if
			}//End if
			if (thisPy>0 && mapArr[thisPy - 1][thisPx].go==0) {//加入上面点
				if (!inArr(mapArr[thisPy - 1][thisPx],closeList)) {//是否在关闭列表中
					if (!inArr(mapArr[thisPy - 1][thisPx],openList)) {//是否在开启列表中
						setGHF(mapArr[thisPy - 1][thisPx],thisPoint,10);//计算GHF值
						openList.push(mapArr[thisPy - 1][thisPx]);//加入节点
					} else {
						checkG(mapArr[thisPy - 1][thisPx],thisPoint);//检查G值
					}//End if
				}//End if
			}//End if
			if (thisPy<h && mapArr[thisPy + 1][thisPx].go==0) {//加入下面点
				if (!inArr(mapArr[thisPy + 1][thisPx],closeList)) {//是否在关闭列表中
					if (!inArr(mapArr[thisPy + 1][thisPx],openList)) {//是否在开启列表中
						setGHF(mapArr[thisPy + 1][thisPx],thisPoint,10);//计算GHF值
						openList.push(mapArr[thisPy + 1][thisPx]);//加入节点
					} else {
						checkG(mapArr[thisPy + 1][thisPx],thisPoint);//检查G值
					}//End if
				}//End if
			}//End if
		}//End Fun
		//判断当前点是否在开启列表中－－－－－－－－－－－－－－－－－－－－－－－－－－－－》
		private function inArr(obj:MovieClip,arr:Array):Boolean {
			for each (var mc:MovieClip in arr) {
				if (obj == mc) {
					return true;
				}//End if
			}//End for
			return false;
		}//End Fun
		
		//设置节点的G/H/F值－－－－－－－－－－－－－－－－－－－－－－－－－－－－》
		private function setGHF(point:MovieClip,thisPoint:MovieClip,G:int):void
		{
			if (!thisPoint.G) {
				thisPoint.G=0;
			}
			point.G=thisPoint.G+G;
			//H值为当前节点的横纵向到重点的节点数×10
			point.H=(Math.abs(point.px - endPoint.px) + Math.abs(point.py - endPoint.py))*10;
			point.F=point.H + point.G;//计算F值
			point.father=thisPoint;//指定父节点
		}//End Fun
		
		//检查新的G值以判断新的路径是否更优
		private function checkG(chkPoint:MovieClip,thisPoint:MovieClip):void {
			var newG:int = thisPoint.G + 10;//新G值为当前节点的G值加上10（因为只检查当前节点的直点）
			if (newG <= chkPoint.G) {//如果新的G值比原来的G值低或相等，说明新的路径会更好
				chkPoint.G=newG;//更新G值
				chkPoint.F=chkPoint.H+newG;//同时F值重新被计算
				chkPoint.father=thisPoint;//将其父节点更新为当前点
			}//End if
		}//End Fun
		
		//获取开启列表中的F值最小的节点，返回的是该节点所在的索引
		private function getMinF():uint {
			var tmpF:uint=100000000;//用以存放最小F值（这里先假定了一个很大的数值）
			var id:uint=0;
			var rid:uint;
			for each (var mc:MovieClip in openList) {
				//如果列表中的当前节点的F值比目前存放的F值小，就将F值更新为当前节点的F值，否则就什么都不做
				//这样循环和列表中所有节点的F值比较完成后，最后用以存放最小F值里的F值就是最小的
				if (mc.F<tmpF) {
					tmpF=mc.F;
					rid=id;//同时更新返加的索引值为当前节点的索引
				}
				id++;//因为for each方法是从数组中的第一个对象开始遍历，而每比一次id＋1刚好可以匹配其索引位置
				//也可以使用FOR遍历，但FLASH中用 FOR EACH方法效率更高
			}//End for
			return rid;//比较完成后返回最小F值所在的索引
		}//End fun
	}//End Class
}//End package