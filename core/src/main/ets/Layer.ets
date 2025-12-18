export abstract class Layer{
  private width: number = 0;
  private height: number = 0;
  private x: number = 0;
  private y: number = 0;
  private visible: boolean = false;
  private offsetX:number = 0;
  private offsetY:number = 0;
  private border:boolean = true;

  constructor(x: number, y: number, width: number, height: number, visible: boolean) {
    this.setSize(width, height);
    this.setPosition(x, y);
    this.setVisible(visible);
  }

  setOffset(x:number,y:number){
    this.offsetX = x;
    this.offsetY = y;
  }

  getOffsetX(){
    return this.offsetX;
  }

  getOffsetY(){
    return this.offsetY;
  }

  setBorder(border:boolean){
    this.border = border;
  }

  isBorder():boolean{
    return this.border;
  }

  setPosition(x: number, y: number) {
    this.x = x;
    this.y = y;
  }

  setSize(width: number, height: number) {
    this.width = width;
    this.height = height;
  }

  setVisible(visible: boolean) {
    this.visible = visible;
  }

  getWidth(): number {
    return this.width;
  }

  getHeight(): number {
    return this.height;
  }

  getX(): number {
    return this.x;
  }

  getY(): number {
    return this.y;
  }

  isVisible(): boolean {
    return this.visible;
  }

  move(dx: number, dy: number) {
    this.x += dx;
    this.y += dy;
  }

  abstract paint(g: CanvasRenderingContext2D);

  abstract tick();

}