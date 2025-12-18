import { Actor } from "./Actor";
import Resources from "../Resources";
import { TiledLayer } from "@ohos/core";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { EnemyTank } from "./tank/EnemyTank";
import { PlayerTank } from "./tank/PlayerTank";
import { Powerup } from "./actor/Powerup";
import { Bullet } from "./actor/Bullet";

export class BattleField extends TiledLayer implements Actor{
  public static NONE: number = -1;
  public static NORTH: number = 0;
  public static EAST: number = 1;
  public static SOUTH: number = 2;
  public static WEST: number = 3;

  private SNOW: number = 1;
  private BRICK_WALL: number = 2;
  private FOREST: number = 3;
  private CONCRETE_WALL: number = 6;
  private WIDTH_IN_TILES: number = 0;
  private HEIGHT_IN_TILES: number = 0;
  private waterFrames: number[][] = [[4, 5], [5, 4]];
  private xTiles:number = 0;
  private yTiles:number = 0;
  private tickCount: number = 0;
  private concreteWallStartTime: number = 0;
  private concreteWallPeriod: number = 30000;

  private enemyPos: number[][] = [[0, 0], [0, 0], [0, 0]];
  private nextEnemyPos: number = 0;

  constructor(xTiles: number, yTiles: number, g: CanvasRenderingContext2D) {
    let tileImage = Resources.getTileImage();
    super(xTiles * 2, yTiles * 2,tileImage, tileImage.width/6, tileImage.height,
      Resources.TILE_WIDTH / 2, Resources.TILE_WIDTH / 2);
    super.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y);
    super.setBorder(Resources.SHOW_BORDER);
    this.xTiles = xTiles;
    this.yTiles = yTiles;
    this.WIDTH_IN_TILES = xTiles * 2;
    this.HEIGHT_IN_TILES = yTiles * 2;
    this.createAnimatedTile(this.waterFrames[0][0]);
    this.createAnimatedTile(this.waterFrames[1][0]);
    //Left
    this.enemyPos[0][0] = 0;
    this.enemyPos[0][1] = 0;
    //Middle
    this.enemyPos[1][0] = Math.floor(xTiles / 2) * Resources.TILE_WIDTH;
    this.enemyPos[1][1] = 0;
    //Right
    this.enemyPos[2][0] = (xTiles-1) * Resources.TILE_WIDTH;
    this.enemyPos[2][1] = 0;
  }

  containsImpassableArea(x: number, y: number, width: number, height: number): boolean {
    let tileWidth: number = Resources.TILE_WIDTH / 2;
    let rowMin: number = Math.floor(y / tileWidth);
    let rowMax: number = Math.floor((y + height - 1) / tileWidth);
    if (rowMax >= this.HEIGHT_IN_TILES) {
      rowMax = this.HEIGHT_IN_TILES - 1;
    }
    let columnMin: number = Math.floor(x / tileWidth);
    if (x < 0 || y < 0 || columnMin > this.WIDTH_IN_TILES - 1 || rowMin > this.HEIGHT_IN_TILES - 1) {
      return true;
    }
    rowMin = Math.min(rowMin, this.getRows() - 1);
    columnMin = Math.min(columnMin, this.getColumns() - 1);
    let columnMax: number = Math.floor((x + width - 1) / tileWidth);
    if (columnMax >= this.WIDTH_IN_TILES) {
      columnMax = this.WIDTH_IN_TILES - 1;
    }
    for (let row = rowMin; row <= rowMax; ++row) {
      for (let column = columnMin; column <= columnMax; ++column) {
        let cell: number = this.getCell(column, row);
        if ((cell < 0) || (cell == this.BRICK_WALL) || (cell == this.CONCRETE_WALL)) {
          return true;
        }
      }
    }
    return false;
  }

  hitWall(x: number, y: number, strength: number): boolean {
    let bRet: boolean = false;
    let tileWidth: number = Resources.TILE_WIDTH / 2;
    let bx = x;
    let by = y ;

    let col: number[] = [0, 0];
    let row: number [] = [0, 0];
    let maxRows: number = this.getRows() - 1;
    let maxCols: number = this.getColumns() - 1;
    col[0] = Math.min(Math.floor((bx - tileWidth / 4) / tileWidth), maxCols);
    row[0] = Math.min(Math.floor((by - tileWidth / 4) / tileWidth), maxRows);

    col[1] = Math.min(Math.floor((bx + tileWidth / 4) / tileWidth), maxCols);
    row[0] = Math.min(Math.floor((by - tileWidth / 4) / tileWidth), maxRows);

    col[0] = Math.min(Math.floor((bx - tileWidth / 4) / tileWidth), maxCols);
    row[1] = Math.min(Math.floor((by + tileWidth / 4) / tileWidth), maxRows);

    col[1] = Math.min(Math.floor((bx + tileWidth / 4) / tileWidth), maxCols);
    row[1] = Math.min(Math.floor((by + tileWidth / 4) / tileWidth), maxRows);

    for (let i = 0; i < 2; i++) {
      for (let j = 0; j < 2; j++) {
        let cell: number = this.getCell(col[i], row[j]);
        if (cell == this.BRICK_WALL && strength > 0) {
          this.setCell(col[i], row[j], 0);
          bRet = true;
        } else if (cell == this.CONCRETE_WALL) {
          if (strength > Bullet.GRADE_DEFAULT) {
            this.setCell(col[i], row[j], 0);
          }
          bRet = true;
        } else if (cell == this.FOREST || cell < 0 || cell == this.SNOW) {
          //here a bullet can destory water, snow field and forest
          //which is unrealistic:) just for fun.
          if (strength > Bullet.GRADE_BREAK_CONCRETE_WALL) {
            this.setCell(col[i], row[j], 0);
            bRet = true;
          }
        }
      }
    }
    return bRet;
  }

  isOnSnow(x: number, y: number): boolean {
    let tileWidth: number = Resources.TILE_WIDTH / 2;
    let row: number = Math.floor(y / tileWidth);
    let column: number = Math.floor(x / tileWidth);
    if (x < 0 || y < 0 || column > this.WIDTH_IN_TILES - 1 || row > this.HEIGHT_IN_TILES - 1) {
      return false;
    }
    row = Math.min(row, this.getRows() - 1);
    column = Math.min(column, this.getColumns() - 1);
    let cell: number = this.getCell(column, row);
    return cell == this.SNOW;
  }


  async initBattlefield(){
    for (let i = 0; i < this.WIDTH_IN_TILES; i += 2){
      for(let j=0;j<this.HEIGHT_IN_TILES;j+=2){
        //模24是希望1/4的战场有填充，3/4战场没填充
        let value: number = Math.floor(Math.abs(Math.random() * 25)) % 24;
        if (value > 17) {
          if (value == 21 || value == 22) {
            //异或后与，奇偶相同为0，奇偶不同为1
            let val: number = -1 - (((i/2) ^ (j/2)) & 1);
            hilog.info(0x0001,"idxval","val=" + val);
            this.duplicateCell(i, j, val);
          } else {
            this.duplicateCell(i, j, value - 17);
          }
        } else {
          this.duplicateCell(i, j, 0);
        }
      }
    }
    this.makeHomeBrickWall();
  }

  makeHomeBrickWall() {
    for (let i = 0; i < 6; i++) {
      for (let j = 0; j < 4; j++) {
        this.setCell(i + Math.floor(this.WIDTH_IN_TILES / 2 - 3), this.HEIGHT_IN_TILES - 4 + j, this.BRICK_WALL);
      }
    }
    this.duplicateCell(Math.floor((this.WIDTH_IN_TILES - 2) / 2), this.HEIGHT_IN_TILES - 2, 0);
    this.concreteWallStartTime = 0;
  }

  makeHomeConcreteWall() {
    //Draw the player's home area.
    for (let i = 0; i < 6; i++) {
      for (let j = 0; j < 4; j++) {
        this.setCell(i + Math.floor((this.WIDTH_IN_TILES / 2) - 3), this.HEIGHT_IN_TILES - 4 + j, this.CONCRETE_WALL);
      }
    }
    //this place will be placed with player's flag.
    this.duplicateCell(Math.floor((this.WIDTH_IN_TILES - 2) / 2), this.HEIGHT_IN_TILES - 2, 0);
    this.concreteWallStartTime = Date.now();
  }

  //从左上角到右下角重复一个正方格
  duplicateCell(x: number, y: number, value: number) {
    let maxCols = this.getColumns() - 1;
    let maxRows = this.getRows() - 1;
    if (x < 0 || x > maxCols || y < 0 || y > maxRows) {
      return;
    }
    this.setCell(x, y, Math.floor(value));
    this.setCell(x + 1, y, Math.floor(value));
    this.setCell(x, y + 1, Math.floor(value));
    this.setCell(x + 1, y + 1, Math.floor(value));
  }

  tick(): void {
    let tickState = (this.tickCount++ >> 1); // slow down x2
    let tile = tickState % 2;
    hilog.info(0x0002,'tick','row=' + tile + ',col=' + Math.floor((tickState % 4) / 2));
    this.setAnimatedTile(-1 - tile, this.waterFrames[tile][Math.floor((tickState % 4) / 2)]);
  }

  getXTiles(){
    return this.xTiles;
  }

  getYTiles(){
    return this.yTiles;
  }

  initEnemyTankPos(tank: EnemyTank) {
    this.nextEnemyPos %= 3;
    let x = this.enemyPos[this.nextEnemyPos][0];
    let y = this.enemyPos[this.nextEnemyPos][1];
    tank.setPosition(x, y);
    this.nextEnemyPos++;
  }

  initPlayerTankPos(tank: PlayerTank) {
    let x = Math.floor(this.xTiles / 2 - 2) * Resources.TILE_WIDTH;
    let y = (this.yTiles-1) * Resources.TILE_WIDTH;
    this.duplicateCell(this.xTiles-5, this.HEIGHT_IN_TILES-2, 0);
    tank.setPosition(x, y);
  }

  initPowerupPos(powerup: Powerup) {
    if (powerup.getType() == Powerup.HOME || powerup.getType() == Powerup.HOME_DESTROYED) {
      let x: number = Math.floor(this.xTiles/2) * Resources.TILE_WIDTH;
      let y: number = (this.yTiles - 1) * Resources.TILE_WIDTH;
      powerup.setPosition(x, y);
    } else {
      let x0: number = Math.floor(this.xTiles/2) * Resources.TILE_WIDTH;
      let y0: number = (this.yTiles - 1) * Resources.TILE_WIDTH;
      let btfWn = Math.floor(this.getWidth()/Resources.TILE_WIDTH) + 10;
      let btfHn = Math.floor(this.getHeight()/Resources.TILE_WIDTH) + 10;
      let x: number = Math.floor(Math.abs(Math.random() * btfWn) % this.xTiles) * Resources.TILE_WIDTH;
      let y: number = Math.floor(Math.abs(Math.random() * btfHn) % this.yTiles) * Resources.TILE_WIDTH;
      //avoid the home cell.
      while (x == x0 && y == y0) {
        x = Math.floor(Math.abs(Math.random() * btfWn) % this.xTiles) * Resources.TILE_WIDTH;
        y = Math.floor(Math.abs(Math.random() * btfHn) % this.yTiles) * Resources.TILE_WIDTH;
      }
      powerup.setPosition(x, y);
    }
  }

}