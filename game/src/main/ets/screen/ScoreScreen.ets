import { PlayerTank } from '../actors/tank/PlayerTank';
import { Tanks } from '../actors/Tanks';
import Resources from '../Resources';
import { GameScene } from './GameScene';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ScoreScreen {
  private w: number = 0;
  private h: number = 0;
  private scoreWidth:number = 0;
  private scoreHeight:number = 0;
  private numWidth:number = 0;
  private numHeight:number = 0;

  private offsetX:number = 0;
  private offsetY:number = 0;
  private highScoreX:number = 0;
  private highScoreY:number = 0;
  private playerScoreX:number = 0;
  private playerScoreY:number = 0;
  private totalNumberX:number = 0;
  private totalNumberY:number = 0;
  private tankNumberPos:number[][] = [[0,0],[0,0],[0,0],[0,0]];
  private isGameOver:boolean = false;
  private enemyType:number = 4;
  private enemyCount:number = 0;
  private totalKilled:number = 0;
  private totalKilledIndex:number = 0;
  private imgScore:ImageBitmap = Resources.getImage(Resources.SCORE_SCREEN);
  private imgNumberWhite:ImageBitmap = Resources.getImage(Resources.NUMBER_WHITE);;
  private imgNumberRed:ImageBitmap = Resources.getImage(Resources.NUMBER_RED);
  private playerTank:PlayerTank = Tanks.getPlayerTank();

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private k:number = 1;
  private intervalID: number = 0;

  build() {
    RelativeContainer() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onAppear(()=>{
          if(Resources.isPlayingSound){
            Resources.playSound(Resources.SCORE_SOUND);
          }
          this.enemyType=4;
          this.enemyCount=5;
          this.totalKilled=0;
          GameScene.enemyTanksCount = [1,2,3,4]
          for(let i=0;i<4;i++){
            let value:number=GameScene.enemyTanksCount[i]*(i+1)*100;
            this.playerTank!.addScore(value);
            this.totalKilled+=GameScene.enemyTanksCount[i];
          }
          this.totalKilledIndex=this.totalKilled;
        })
        .onSizeChange((oldValue,newValue)=>{
          this.w = JSON.parse(JSON.stringify(newValue)).width;
          this.h = JSON.parse(JSON.stringify(newValue)).height;
          this.scoreWidth = this.w * .9
          this.k = (this.scoreWidth  / this.imgScore.width) * 1.5
          this.scoreHeight = this.imgScore.height * this.k
          this.offsetX = (this.w - this.scoreWidth) / 2;
          this.offsetY = (this.h - this.scoreHeight) / 2;

          this.highScoreX = this.w * 2 /3;
          this.highScoreY = this.offsetY;
          this.playerScoreX = this.w * 2 /3;
          this.playerScoreY = this.offsetY + this.scoreHeight *.19;

          this.numHeight = this.scoreHeight * .14
          this.numWidth = this.scoreWidth *.15

          for (let i = 0; i < 4; i++) {
            this.tankNumberPos[i][0] = this.w * .655
            this.tankNumberPos[i][1] = this.offsetY + this.scoreHeight * .42 + i*this.numHeight;
          }
          this.totalNumberX = this.w * .655;
          this.totalNumberY = this.offsetY + this.scoreHeight * .95;
        })
        .onReady(()=>{
          this.intervalID = setInterval(() => {
            this.draw(this.context);
            if(this.enemyCount>=GameScene.enemyTanksCount[this.enemyType]){
              this.enemyCount=0;
              this.enemyType++;
            }
            this.enemyCount++;
            this.totalKilledIndex--;
            if(this.totalKilledIndex<=0 && this.enemyType>=3){
              clearInterval(this.intervalID);
              let a = setInterval(()=>{
                clearInterval(a)

                router.pushUrl({ url: 'screen/GameScene' })
              },3000)
            }
          }, 500)
        })
    }
    .height('100%')
    .width('100%')
  }

  draw(g:CanvasRenderingContext2D){
    this.context.fillStyle = '#000000'
    this.context.fillRect(0, 0, this.w, this.h)
    this.context.drawImage(
      this.imgScore,0,0,this.imgScore?.width,this.imgScore?.height,
      this.offsetX,this.offsetY,this.scoreWidth,this.scoreHeight
    )
    this.drawNumber(this.context,Resources.highScore,this.highScoreX,this.highScoreY,true);
    this.drawNumber(this.context,this.playerTank.getScore(),this.playerScoreX,this.playerScoreY,true);

    if(this.enemyType>3){
      this.enemyType=3;
    }
    for(let i=0;i<this.enemyType;i++){
      this.drawNumber(this.context,GameScene.enemyTanksCount[i]*100,
        this.tankNumberPos[i][0], this.tankNumberPos[i][1],false
      );
      this.drawNumber(this.context,GameScene.enemyTanksCount[i],
        this.tankNumberPos[i][0]-this.scoreWidth*.3, this.tankNumberPos[i][1],true
      );
    }
    this.drawNumber(this.context,this.enemyCount*100,
      this.tankNumberPos[this.enemyType][0], this.tankNumberPos[this.enemyType][1],false
    );
    this.drawNumber(this.context,this.enemyCount,
      this.tankNumberPos[this.enemyType][0]-this.scoreWidth*.3, this.tankNumberPos[this.enemyType][1],true
    );
    this.drawNumber(this.context,this.totalKilled,this.totalNumberX,this.totalNumberY,false);
  }


  drawNumber(g:CanvasRenderingContext2D, number:number, x:number, y:number, isRed:boolean) {
    console.log("===>>> number=" + number)
    let imageNumber:ImageBitmap|null=null;
    if(isRed){
      imageNumber=this.imgNumberRed;
    }else{
      imageNumber=this.imgNumberWhite;
    }
    let strNumber:string = number.toString();
    let srcWidth:number = imageNumber.width/10;
    let srcHeight:number = imageNumber.height;
    let dstWidth = srcWidth * this.k;
    let dstHeight = srcHeight * this.k;

    for(let i=0;i<strNumber.length;i++){
      let ch:string = strNumber.charAt(i);
      let index:number = parseInt(ch);
      if(isRed){
        g.drawImage(imageNumber,index * srcWidth,0,srcWidth,srcHeight,x+i*dstWidth,y,dstWidth,dstHeight);
      }else{
        g.drawImage(imageNumber,index * srcWidth,0,srcWidth,srcHeight,x+i*dstWidth,y,dstWidth,dstHeight)
      }
    }
  }
}