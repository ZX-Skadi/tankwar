import { hilog } from '@kit.PerformanceAnalysisKit';
import { Sprite } from '@ohos/core';
import Resources from '../Resources';
import { KeyCode } from '@kit.InputKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct StartScreen {
  private w: number = 0;
  private h: number = 0;
  private offsetX: number = 0;
  private offsetY: number = 0;
  private pointerPos: number[][] = [[0, 0], [0, 0]];
  private currentPointerIndex: number = 0;
  private imgGameHelp: ImageBitmap | undefined | null;
  private imgTurnOnSound: ImageBitmap | undefined | null;
  private pointer:Sprite | undefined | null;
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    RelativeContainer(){
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onAppear(()=>{
          if(!Resources.loaded){
            Resources.loadResources();
          }
        })
        .onSizeChange((oldValue,newValue)=>{
          this.w = JSON.parse(JSON.stringify(newValue)).width;
          this.h = JSON.parse(JSON.stringify(newValue)).height;

          this.imgGameHelp = Resources.getImage(Resources.GAME_HELP);
          this.imgTurnOnSound = Resources.getImage(Resources.TURN_SOUND);
          this.offsetX = this.w * .2;
          this.offsetY = this.h * .2;

          let players: ImageBitmap = Resources.getImage(Resources.PLAYER)
          let tkWidth = players.width / 9;
          let tkHeight = players.height / 4;
          let offCanvas: OffscreenCanvas = new OffscreenCanvas(tkWidth, tkHeight)
          let offContext = offCanvas.getContext("2d", this.settings)
          offContext.drawImage(players, 0, tkHeight, tkWidth, tkHeight, 0, 0, tkWidth, tkHeight)
          this.pointer = new Sprite(offContext.transferToImageBitmap(),tkWidth,tkHeight,this.w * .06,this.w * .06)
          this.pointer.setBorder(Resources.SHOW_BORDER);

          this.pointerPos[0][0] = this.offsetX + this.w * .17;
          this.pointerPos[0][1] = this.offsetY + this.h * .31;
          this.pointerPos[1][0] = this.offsetX + this.w * .17;
          this.pointerPos[1][1] = this.offsetY + this.h * .353;

          this.pointer.setPosition(this.pointerPos[0][0], this.pointerPos[0][1]);
          this.pointer.paint(this.context);
        })
        .onReady(()=>{
          this.draw();
        })
    }
    .height('100%')
    .width('100%')
    .onKeyEvent((e:KeyEvent)=>{
      if(e.type === KeyType.Down){
        switch(e.keyCode){
          case KeyCode.KEYCODE_2:
          case KeyCode.KEYCODE_DPAD_DOWN:
            this.currentPointerIndex++;
            if (this.currentPointerIndex > 1) {
              this.currentPointerIndex = 0;
            }
            break;
          case KeyCode.KEYCODE_8:
          case KeyCode.KEYCODE_DPAD_UP:
            this.currentPointerIndex--;
            if (this.currentPointerIndex < 0) {
              this.currentPointerIndex = 1;
            }
            break;
          case KeyCode.KEYCODE_4:
          case KeyCode.KEYCODE_DPAD_LEFT:
            this.currentPointerIndex--;
            if (this.currentPointerIndex < 0) {
              this.currentPointerIndex = 1;
            }
            break;
          case KeyCode.KEYCODE_6:
          case KeyCode.KEYCODE_DPAD_RIGHT:
            this.currentPointerIndex++;
            if (this.currentPointerIndex > 1) {
              this.currentPointerIndex = 0;
            }
            break;
          case KeyCode.KEYCODE_5:
          case KeyCode.KEYCODE_SPACE:
          case KeyCode.KEYCODE_ENTER:
            if (this.currentPointerIndex == 0) {
              Resources.isPlayingSound = true;
            } else {
              Resources.isPlayingSound = false;
            }
            router.replaceUrl({ url: 'screen/SplashScreen' })
            break;
        }
        this.draw();
      }
    })
  }

  draw(){
    hilog.info(0x000005,'startScreen',"=====> draw()");

    this.context.fillStyle = '#000000';
    this.context.fillRect(0, 0, this.w, this.h)

    this.context.drawImage(this.imgGameHelp, this.offsetX, this.offsetY, this.w * .6, this.h * .6)
    this.context.drawImage(this.imgTurnOnSound, this.offsetX, this.offsetY + this.h * .25, this.w * .6, this.h * .13)

    this.pointer!.setPosition(this.pointerPos[this.currentPointerIndex][0], this.pointerPos[this.currentPointerIndex][1]);
    this.pointer!.paint(this.context);
  }
}