import { Layer } from "./Layer";

export class TiledLayer extends Layer{
  private rows:number = 0;
  private cols:number = 0;
  private tileHeight:number =0 ;
  private tileWidth:number = 0;
  private frameHeight:number =0 ;
  private frameWidth:number = 0;
  private numStaticTiles:number = 0;
  private tiles:number[][] = [];
  private animatedTiles:number[] = [];
  private numAnimatedTiles:number = 0;
  private img:ImageBitmap|null|undefined;

  constructor(cols:number, rows:number,img:ImageBitmap, frameWidth:number,
    frameHeight:number, tileWidth:number, tileHeight:number
  ) {
    super(0, 0, cols * tileWidth, rows * tileHeight, true);
    this.img = img;
    this.cols = cols;
    this.rows = rows;
    this.tileWidth = tileWidth;
    this.tileHeight = tileHeight;
    this.frameWidth = frameWidth;
    this.frameHeight = frameHeight;
    this.numStaticTiles = Math.floor(img.width / frameWidth) * Math.floor(img.height / frameHeight);
    for (let i = 0; i < rows; i++) {
      this.tiles[i] = [];
      for (let j = 0; j < cols; j++) {
        this.tiles[i][j] = 0;
      }
    }
    this.animatedTiles = [0,0,0,0,0];
    this.numAnimatedTiles = 0;
  }


  paint(g: CanvasRenderingContext2D): void {
    if (!this.isVisible())
      return;

    let x:number = this.getX();
    let y:number = this.getY();

    let c0:number = 0;
    let r0:number = 0;
    let cMax:number = this.getColumns();
    let rMax:number = this.getRows();

    let tW:number = this.frameWidth
    let tH:number = this.frameHeight

    let x0 = x;
    let imgCols = Math.floor(this.img!.width / tW);
    for (let r = r0; r < rMax; r++, y += this.tileHeight) {
      x = x0;
      for (let c = c0; c < cMax; c++, x += this.tileWidth) {
        let tile = this.getCell(c, r);
        if (tile < 0)
          tile = this.getAnimatedTile(tile);
        if (tile == 0)
          continue;

        tile--;

        let xSrc = tW * Math.floor(tile % imgCols);
        let ySrc = Math.floor(tile / imgCols) * tH;

        //a水平缩放，b垂直倾斜，c水平倾斜，d垂直缩放，e水平移动vp，f垂直移动vp
        g.setTransform(1,0,0,1,this.getOffsetX(),this.getOffsetY());
        g.drawImage(this.img, xSrc, ySrc, tW, tH,x,y,this.tileWidth,this.tileHeight);
        g.resetTransform()
        if(this.isBorder()){
          g.lineWidth = 1
          g.strokeStyle= '#ffffff'
          g.strokeRect(x,y, this.tileWidth, this.tileHeight)
        }
      }
    }
  }

  tick(): void { }

  createAnimatedTile(staticTileIndex:number):number {
    if (this.numAnimatedTiles == this.animatedTiles.length) {
      let temp:number []= []
      for(let i=0;i<this.numAnimatedTiles;i++){
        temp.push(this.animatedTiles[i]);
      }
      this.animatedTiles = temp;
    }

    this.animatedTiles[this.numAnimatedTiles] = staticTileIndex;
    this.numAnimatedTiles++;

    return -this.numAnimatedTiles;
  }

  getAnimatedTile(index:number):number {
    let idx = -1 - index;
    return this.animatedTiles[idx];
  }

  getCell(col:number, row:number):number {
    return this.tiles[row][col];
  }

  setCell(col:number, row:number, index:number) {
    this.tiles[row][col] = index;
  }

  getColumns():number {
    return this.cols;
  }

  getRows():number {
    return this.rows;
  }

  getCellWidth():number {
    return this.tileWidth;
  }

  getCellHeight():number {
    return this.tileHeight;
  }

  setAnimatedTile(index:number, staticTileIndex:number) {
    let idx = -index - 1;
    this.animatedTiles[idx] = staticTileIndex;
  }


}
