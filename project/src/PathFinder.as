package
{
	import flash.geom.Point;
	
	/**
	 * 寻路,结合二叉树 
	 */
	public class PathFinder
	{
		private var _mapData:Array;
		private var _openList:Array;
		private var _mapStatus:Array;
		private static const D_COST:int = 10;
		private static const HV_COST:int = 10;
		public static var CLOSED:int = 1;
		private static const MAX_COUNT:int = 50000;//最大循环检查次数,2000
		private var checkCount:int;
		
		public function PathFinder()
		{
			_openList = new Array();
		}
		/**
		 * 删除开放列表中第一位,并重新排位置以至于第一位的F值最小 
		 */		
		private function shiftOpenList():void
		{
			if(_openList.length == 1){
				_openList.length = 0;
				return;
			}
			_openList[0] = _openList.pop();
			_mapStatus[_openList[0].y][_openList[0].x].openIndex = 0;
			var loc1:int = 1;
			var loc2:int;
			while(true){
				loc2 = loc1;
				if(2 * loc2 <= _openList.length){
					//判断二叉树左边那位
					if(_mapStatus[_openList[loc1 - 1].y][_openList[loc1 - 1].x].F > 
						_mapStatus[_openList[2 * loc2 - 1].y][_openList[2 * loc2 - 1].x].F){
						loc1 = 2 * loc2;
					}
					//判断二叉树右边那位
					if(2 * loc2 + 1 <= _openList.length){
						if(_mapStatus[_openList[loc1 - 1].y][_openList[loc1 - 1].x].F > 
							_mapStatus[_openList[2 * loc2].y][_openList[2 * loc2].x].F){
							loc1 = 2 * loc2 + 1;
						}
					}
				}
				if(loc2 == loc1){
					break;
				}else{
					//交换位置
					var loc3:Object = _openList[loc2 - 1];
					var loc4:Object = _openList[loc1 - 1];
					_openList[loc2 - 1] = loc4;
					_openList[loc1 - 1] = loc3;
					_mapStatus[loc3.y][loc3.x].openIndex = loc1 - 1;
					_mapStatus[loc4.y][loc4.x].openIndex = loc2 - 1;
				}
			}
		}
		/**
		 * 是否未被检查过 
		 * @param y
		 * @param x
		 * @return 
		 */		
		private function isOpen(y:int, x:int):Boolean
		{
			var obj:* = _mapStatus[y];
			if(obj != undefined){
				obj = obj[x];
				if(obj != undefined){
					return obj.openIndex != -1;
				}
				return false;
			}
			return false;
		}
		/**
		 * 是否被检查过的 
		 * @param y
		 * @param x
		 * @return 
		 */		
		private function isClosed(y:int, x:int):Boolean
		{
			var obj:* = _mapStatus[y];
			if(obj != undefined){
				obj = obj[x];
				if(obj != undefined){
					return obj.openIndex == -1;
				}
				return false;
			}
			return false;
		}
		public function set mapData(arr:Array):void
		{
			_mapData = arr;
			_openList.length = 0;
			_mapStatus = [];
		}
		/**
		 * 排列开放列表,直到第一位的F值为最小 
		 * @param index
		 */		
		private function resortOpoenList(index:int):void
		{
			var loc2:int;
			var loc3:Object;
			var loc4:Object;
			var loc5:Object;
			var loc6:Object;
			while(index > 1){
				loc2 = Math.floor(index / 2);
				loc3 = _openList[index - 1];
				loc4 = _openList[loc2 - 1];
				loc5 = _mapStatus[loc3.y][loc3.x];
				loc6 = _mapStatus[loc4.y][loc4.x];
				if(loc5.F < loc6.F){
					_openList[index - 1] = loc4;
					_openList[loc2 - 1] = loc3;
					loc5.openIndex = loc2 - 1;
					loc6.openIndex = index - 1;
					index = loc2;
				}else{
					break;
				}
			}	
		}
		/**
		 * 寻路
		 * @param sx
		 * @param sy
		 * @param ex
		 * @param ey
		 * @param max 最大的计算次数
		 * @return 返回格子坐标数组
		 */		
		public function findpath(sx:int, sy:int, ex:int, ey:int, max:int=50000):Array
		{
			if(_mapData[ey][ex] == CLOSED){
				return null;
			}
			var yLen:int = _mapData.length;
			var xLen:int = _mapData[0].length;
			_openList.length = 0;
			_mapStatus = [];
			_openList.push(new Point(sx, sy));
			_mapStatus[sy] = [];
			_mapStatus[sy][sx] = {parent:null, H:0, F:0, G:0, openIndex:0};
			checkCount = 1;
			var check:Point = new Point(-1, -1);
			while(_openList.length > 0 && !isClosed(ey, ex)){
				check = _openList[0];
				var checkX:int = check.x;
				var checkY:int = check.y;
				_mapStatus[checkY][checkX].openIndex = -1;
				shiftOpenList();
				var prevY:int = checkY - 1;
				var prevX:int;
				while(prevY < checkY + 2){
					prevX = checkX - 1;
					while(prevX < checkX + 2){
						if(prevY >= 0 && prevY < yLen && prevX >= 0 && prevX < xLen && !(prevY == checkY && prevX == checkX) &&
							(prevY == checkY || prevX == checkX ||(_mapData[prevY][checkX] != CLOSED && _mapData[checkY][prevX] != CLOSED))){
							if(_mapData[prevY][prevX] != CLOSED){
								if(!isClosed(prevY, prevX)){
									//(prevY == checkY || prevX == checkX) ? HV_COST : D_COST
									var newG:Number = int(_mapStatus[checkY][checkX].G) + 10;
									if(isOpen(prevY, prevX)){
										if(newG < _mapStatus[prevY][prevX].G){
											_mapStatus[prevY][prevX].parent = check;
											_mapStatus[prevY][prevX].F = newG + _mapStatus[prevY][prevX].H;
											resortOpoenList(_mapStatus[prevY][prevX].openIndex + 1);
										}
									}else{
										var absY:int = prevY - ey;
										absY = absY > 0 ? absY : -absY;
										var absX:int = prevX - ex;
										absX = absX > 0 ? absX : -absX;
										var newH:int = (absY + absX) * 10;
										_openList.push(new Point(prevX, prevY));
										if(!_mapStatus[prevY]){
											_mapStatus[prevY] = [];
										}
										_mapStatus[prevY][prevX] = {parent:check, H:newH, G:newG, F:newG + newH, openIndex:_openList.length - 1};
										resortOpoenList(_openList.length);
									}
								}
							}
						}
						prevX ++;
					}
					prevY ++;
				}
				checkCount ++;
				if(checkCount > max){
					if(checkCount > MAX_COUNT)
						trace("已经超过最大数量！");
					break;
				}
			}
			var isClose:Boolean = isClosed(ey, ex);
			if(isClose){
				var arr:Array = new Array();
				var end:Point = new Point(ex, ey);
				while(end.y != sy || end.x != sx){
					arr.push(end);
					end = _mapStatus[end.y][end.x].parent;
				}
				end.x = sx;
				end.y = sy;
				arr.push(end);
				arr.reverse();
				return arr;
			}
			return null;
		}
	}
}