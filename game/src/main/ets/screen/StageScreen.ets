import { KeyCode } from '@kit.InputKit';
import { router } from '@kit.ArkUI';
import Resources from '../Resources';

@Entry
@Component
struct StageScreen {
  private w: number = 0;
  private h: number = 0;
  private offsetX: number = 0;
  private offsetY: number = 0;
  private imgPosY: number = 0;
  private imgPosX: number = 0;
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private intervalID:number = 0;

  build() {
    RelativeContainer() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onAppear(()=>{
          this.imgPosY = 0;
          this.imgPosX = 0;
        })
        .onSizeChange((oldValue, newValue) => {
          this.w = JSON.parse(JSON.stringify(newValue)).width;
          this.h = JSON.parse(JSON.stringify(newValue)).height;

          this.offsetX = this.w / 2;
          this.offsetY = this.h / 2;
        })
        .onReady(() => {
          let f = true;
          let rgb:string = this.rndRGB();
          this.intervalID = setInterval(() => {
            if(Resources.stageFromTop2Bottom){
              this.imgPosY += 8;
              this.context.fillStyle = rgb
              this.context.fillRect(0, 0, this.w, this.imgPosY)
              this.context.fillRect(0, this.h - this.imgPosY, this.w, this.imgPosY)
              if (this.imgPosY > this.h / 2) {
                f = false;
              }
            }else{
              this.imgPosX += 8;
              this.context.fillStyle = rgb
              this.context.fillRect(0, 0, this.imgPosX, this.h)
              this.context.fillRect(this.w-this.imgPosX, 0, this.imgPosX, this.h)
              if(this.imgPosX > this.w/2){
                f = false;
              }
            }
            if(!f){
              clearInterval(this.intervalID)
              Resources.stageFromTop2Bottom = !Resources.stageFromTop2Bottom;
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
            Resources.gameLevel--;
            if (Resources.gameLevel < 1) {
              Resources.gameLevel = 1;
            }
            break;
          case KeyCode.KEYCODE_8:
          case KeyCode.KEYCODE_DPAD_UP:
            Resources.gameLevel++;
            if (Resources.gameLevel > 50) {
              Resources.gameLevel = 50;
            }
            break;
          case KeyCode.KEYCODE_4:
          case KeyCode.KEYCODE_DPAD_LEFT:
            router.replace({ url: 'screen/SplashScreen' })
            break;
          case KeyCode.KEYCODE_6:
          case KeyCode.KEYCODE_DPAD_RIGHT:
            router.pushUrl({ url: 'screen/GameScene' })
            break;
          case KeyCode.KEYCODE_5:
          case KeyCode.KEYCODE_SPACE:
          case KeyCode.KEYCODE_ENTER:
            router.pushUrl({ url: 'screen/GameScene' })
            break;
        }
        this.draw()
      }
    })
  }

  draw() {
    this.context.fillStyle = '#f0f0f0'
    this.context.fillRect(0, 0, this.w, this.h)

    this.context.fillStyle = '#000000'
    let fz:number = this.w * .2;
    this.context.font = fz.toFixed() + 'px sans-serif bold'
    this.context.fillText("STATE " + Resources.gameLevel,this.offsetX*.75,this.offsetY);
  }

  rndRGB():string{
    let rgb = 'rgb(';
    rgb = rgb +Math.floor(Math.random() * 255) + ","
    rgb = rgb + Math.floor(Math.random() * 255) +","
    rgb = rgb + Math.floor(Math.random()*255) + ")"
    return   rgb
  }

}