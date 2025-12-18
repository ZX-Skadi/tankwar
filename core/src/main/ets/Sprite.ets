import { Layer } from "./Layer";
import { LayerRect } from "./LayerRect";

export class Sprite extends Layer{
  private sequence: number[] | null = null;
  private frame: number = 0;
  private frameWidth: number = 0;
  private frameHeight: number = 0;
  private cols: number = 0;
  private rows: number = 0;
  private collX: number = 0;
  private collY: number = 0;
  private collWidth: number = 0;
  private collHeight: number = 0;
  private img: ImageBitmap;
  private direction: number = -1;
  private speed: number = 0;
  private type: number = 0;

  constructor(img:ImageBitmap,frameWidth:number,frameHeight:number,tileWidth:number,tileHeight:number) {
    super(0,0,tileWidth,tileHeight,true);
    this.img = img;
    this.cols = Math.floor(img.width / frameWidth);
    this.rows = Math.floor(img.height / frameHeight);
    this.frameWidth = frameWidth;
    this.frameHeight = frameHeight;
    this.collX = 0
    this.collY = 0;
    this.collWidth = tileWidth;
    this.collHeight = tileHeight;
  }

  tick(): void {
  }

  paint(g: CanvasRenderingContext2D): void {
    if (!this.isVisible()) {
      return;
    }
    let f = (this.sequence == null) ? this.frame : this.sequence[this.frame];
    let w = this.frameWidth;
    let h = this.frameHeight;
    let fx = w * Math.floor(f % this.cols);
    let fy = h * Math.floor(f / this.cols);
    this.collX = this.getX();
    this.collY = this.getY();

    g.setTransform(1, 0, 0, 1, this.getOffsetX(), this.getOffsetY());
    g.drawImage(this.img, fx, fy, w, h, this.collX, this.collY, this.collWidth, this.collHeight);
    g.resetTransform();
    if(this.isBorder()){
      g.lineWidth = 1
      g.strokeStyle = '#0000ff'
      g.strokeRect(this.collX, this.collY, this.collWidth, this.collHeight)
    }
  }

  collidesWithSprite(other:Sprite){
    if(!other.isVisible() || !this.isVisible())
      return false;

    return this.collides(
      this.getX(),this.getY(),this.collWidth,this.collHeight,
      other.getX(),other.getY(),other.getCollWidth(),other.getCollHeight()
    );
  }

  collides(sx:number,sy:number,sw:number,sh:number,dx:number,dy:number,dw:number,dh:number):boolean {
    const rectA : LayerRect = {left:sx,top:sy,right:sx+sw,bottom:sy+sh}
    const rectB : LayerRect = {left:dx,top:dy,right:dx+dw,bottom:dy+dh}
    const noCollides = rectA.right < rectB.left || rectA.left > rectB.right
      || rectA.bottom < rectB.top || rectA.top > rectB.bottom
    return !noCollides
  }

  setDirection(direction:number){
    this.direction = direction;
  }

  getDirection():number{
    return this.direction;
  }

  setSpeed(speed:number){
    this.speed = speed;
  }

  getSpeed():number{
    return this.speed;
  }


  setType(type:number){
    this.type = type;
  }

  getType():number{
    return this.type;
  }

  getCollX() {
    return this.collX;
  }

  getCollY() {
    return this.collY;
  }

  getCollWidth() {
    return this.collWidth;
  }

  getCollHeight() {
    return this.collHeight;
  }

  setFrameSequence(sequence: number[]) {
    if (sequence == null) {
      this.sequence = null;
      return;
    }

    let max = (this.rows * this.cols) - 1;
    let l = sequence.length;

    if (l == 0) {
      throw new Error("Illegal Argument Exception");
    }

    for (let i = 0; i < l; i++) {
      let value = sequence[i];
      if (value > max || value < 0) {
        throw new Error("Array Index Out Of Bounds Exception");
      }
    }

    this.sequence = sequence;
    this.frame = 0;
  }

  getFrame(): number {
    return this.frame;
  }

  getFrameSequenceLength(): number {
    return (this.sequence == null) ? this.rows * this.cols : this.sequence.length;
  }

  setFrame(frame: number) {
    let l: number = (this.sequence == null) ? this.rows * this.cols : this.sequence.length;
    if (frame < 0 || frame >= l) {
      throw new Error("Index Out Of Bounds Exception");
    }
    this.frame = frame;
  }

  nextFrame() {
    if (this.frame == ((this.sequence == null) ? this.rows * this.cols : this.sequence.length) - 1) {
      this.frame = 0;
    } else {
      this.frame++;
    }
  }

  prevFrame() {
    if (this.frame == 0) {
      this.frame = ((this.sequence == null) ? this.rows * this.cols : this.sequence.length) - 1;
    } else {
      this.frame--;
    }
  }

  setImage(img: ImageBitmap, frameWidth: number, frameHeight: number,tileWidth:number,tileHeight:number) {
    this.img = img;
    this.frameWidth = frameWidth
    this.frameHeight = frameHeight
    this.collWidth = tileWidth;
    this.collHeight = tileHeight;
    this.setSize(tileWidth, tileHeight);
    this.move(0, 0);
  }

}