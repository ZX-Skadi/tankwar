import { KeyCode } from '@kit.InputKit';
import { router } from '@kit.ArkUI';
import Resources from '../Resources';
import { Sprite } from '@ohos/core';

@Entry
@Component
struct SplashScreen {
  private w: number = 0;
  private h: number = 0;
  private offsetX: number = 0;
  private offsetY: number = 0;
  private pointerPos: number[][] = [[0, 0], [0, 0], [0, 0]];
  private currentPointerIndex: number = 0;
  private imgPosY: number = 0;
  private imgSplash: ImageBitmap | null | undefined;
  private imgGuidebee: ImageBitmap | null | undefined;
  private intervalID: number = 0;
  private pointer: Sprite | null | undefined;
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    RelativeContainer() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onSizeChange((oldValue, newValue) => {
          this.w = JSON.parse(JSON.stringify(newValue)).width;
          this.h = JSON.parse(JSON.stringify(newValue)).height;

          this.imgSplash = Resources.getImage(Resources.SPLASH);
          this.imgGuidebee = Resources.getImage(Resources.GUIDEBEE_LOGO);
          this.offsetX = this.w * .2;
          this.offsetY = this.h * .2;

          let players: ImageBitmap = Resources.getImage(Resources.PLAYER)
          let tkWidth = players.width / 9;
          let tkHeight = players.height / 4;
          let offCanvas: OffscreenCanvas = new OffscreenCanvas(tkWidth, tkHeight)
          let offContext = offCanvas.getContext("2d", this.settings)
          offContext.drawImage(players, 0, tkHeight, tkWidth, tkHeight, 0, 0, tkWidth, tkHeight)
          this.pointer = new Sprite(offContext.transferToImageBitmap(), tkWidth, tkHeight, this.w * .06, this.w * .06)
          this.pointer.setBorder(Resources.SHOW_BORDER)

          this.pointerPos[0][0] = this.offsetX + this.w * .12;
          this.pointerPos[0][1] = this.offsetY + this.h * .228;
          this.pointerPos[1][0] = this.offsetX + this.w * .12;
          this.pointerPos[1][1] = this.offsetY + this.h * .265;
          this.pointerPos[2][0] = this.offsetX + this.w * .12;
          this.pointerPos[2][1] = this.offsetY + this.h * .302;

          this.pointer.setPosition(this.pointerPos[0][0], this.pointerPos[0][1]);
          this.pointer.paint(this.context);
        })
        .onReady(() => {
          this.imgPosY = this.h;
          this.intervalID = setInterval(() => {
            this.imgPosY -= 8;
            this.context.fillStyle = '#000000'
            this.context.fillRect(0, 0, this.w, this.h)
            this.context.drawImage(this.imgSplash, 0, 2, this.imgSplash!.width, this.imgSplash!.height - 2,
              this.offsetX, this.imgPosY, this.w * .6, this.h * .5
            )
            this.context.drawImage(this.imgGuidebee, this.offsetX,
              this.imgPosY + this.h * .35, this.w * .6, this.h * .2
            )
            if (this.imgPosY <= this.offsetY) {
              clearInterval(this.intervalID)
              this.draw()
            }
          }, 100)
        })
    }
    .height('100%')
    .width('100%')
    .onKeyEvent((e: KeyEvent) => {
      if (e.type === KeyType.Down) {
        switch (e.keyCode) {
          case KeyCode.KEYCODE_2:
          case KeyCode.KEYCODE_DPAD_DOWN:
            this.currentPointerIndex++;
            if (this.currentPointerIndex > 2) {
              this.currentPointerIndex = 0;
            }
            break;
          case KeyCode.KEYCODE_8:
          case KeyCode.KEYCODE_DPAD_UP:
            this.currentPointerIndex--;
            if (this.currentPointerIndex < 0) {
              this.currentPointerIndex = 2;
            }
            break;
          case KeyCode.KEYCODE_4:
          case KeyCode.KEYCODE_DPAD_LEFT:
            router.replaceUrl({ url: 'screen/StartScreen' })
            break;
          case KeyCode.KEYCODE_6:
          case KeyCode.KEYCODE_DPAD_RIGHT:
            router.replaceUrl({ url: 'screen/StageScreen' })
            break;
          case KeyCode.KEYCODE_5:
          case KeyCode.KEYCODE_SPACE:
          case KeyCode.KEYCODE_ENTER:
            router.replaceUrl({ url: 'screen/StageScreen' })
            break;
        }
        this.draw()
      }
    })
  }

  draw() {
    this.context.fillStyle = '#000000'
    this.context.fillRect(0, 0, this.w, this.h)
    this.context.drawImage(this.imgSplash, 0, 2, this.imgSplash!.width, this.imgSplash!.height - 2,
      this.offsetX, this.imgPosY, this.w * .6, this.h * .5
    )
    this.context.drawImage(this.imgGuidebee, this.offsetX, this.imgPosY + this.h * .35, this.w * .6, this.h * .2)
    this.pointer!.setPosition(
      this.pointerPos[this.currentPointerIndex][0],
      this.pointerPos[this.currentPointerIndex][1]
    );
    this.pointer!.paint(this.context);
  }

}


