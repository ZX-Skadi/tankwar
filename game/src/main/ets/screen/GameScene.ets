import { Event } from '@kit.ArkTS';
import { resourceManager } from '@kit.LocalizationKit';
import { Layer, LayerManager, Sprite } from '@ohos/core';
import { Actor } from '../actors/Actor';
import { Powerup } from '../actors/actor/Powerup';
import { BattleField } from '../actors/BattleField';
import { Bullets } from '../actors/Bullets';
import { Powerups } from '../actors/Powerups';
import { EnemyTank } from '../actors/tank/EnemyTank';
import { PlayerTank } from '../actors/tank/PlayerTank';
import { Tanks } from '../actors/Tanks';
import Resources from '../Resources';
import ResourceManager from '../Resources';
import { KeyCode } from '@kit.InputKit';
import { Explosions } from '../actors/Explosions';
import { Scores } from '../actors/Scores';
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct GameScene {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  private sceneWidth: number = 0;
  private sceneHeight: number = 0;
  private barHeight: number = 0;

  private battleField: BattleField | null | undefined;
  private layerManager: LayerManager = new LayerManager();
  private totalLayers: number = 0;

  public static TOTAL_ENEMY_TANKS: number = 20;
  public static enemyTankRemains: number = GameScene.TOTAL_ENEMY_TANKS;
  public static canPutPowerup: boolean = false;
  public static enemyTanksCount: number[] = [1, 1, 1, 1];
  private putPowerupStartTime: number = 0;
  private putPowerupPeriod: number = 120000;


  private playerTank: PlayerTank | null | undefined;
  private defaultPlayerLive: number = 9;
  private intervalID: number = 0;
  private isGameover: boolean = false;
  private enemySpawnStartTime: number = 0;
  private enemySpawnPeriod: number = 20000;
  private timeTaken: number = 0;

  private gameStatus: Sprite | null = null;
  private imgGameover: ImageBitmap = Resources.getImage(Resources.GAME_OVER_SMALL);
  private imgPause: ImageBitmap = Resources.getImage(Resources.PAUSE);
  private imgNumberBlack: ImageBitmap = Resources.getImage(Resources.NUMBER_BLACK);
  private imgEnemyIcon: ImageBitmap = Resources.getImage(Resources.ENEMY_ICON);
  private imgIP: ImageBitmap = Resources.getImage(Resources.IP);
  private imgFlag: ImageBitmap = Resources.getImage(Resources.FLAG);
  private imgPlayerIcon: ImageBitmap = Resources.getImage(Resources.PLAYER_ICON);

  private marginX: number = 0;
  private marginY: number = 0;

  private flagHeight:number = 0;
  private flagWidth:number=0;
  private enemyHeight:number = 0;
  private enemyWidth:number = 0;
  private playerHeight:number=0;
  private playerWidth:number = 0;
  private ipHeight:number = 0;
  private ipWidth:number=0;
  private iconWidth:number = 0;
  private gameOverWidth:number = 0;
  private gameOverHeight:number = 0;

  private gameOverStartTime: number = 0;
  private gameOverPeriod: number = 8000;


  build() {
    RelativeContainer() {
      Canvas(this.context)
        .width('100%')
        .height('100%')
        .onAppear(()=>{
          if(!Resources.loaded){
            Resources.loadResources();
          }
        })
        .onSizeChange(async (oldValue,newValue)=>{
          this.sceneWidth = JSON.parse(JSON.stringify(newValue)).width;
          this.sceneHeight = JSON.parse(JSON.stringify(newValue)).height;
          this.barHeight = this.sceneHeight * .08

          let xTiles: number = Math.floor(this.sceneWidth / ResourceManager.TILE_WIDTH);
          if (xTiles % 2 == 0) {
            xTiles--;
          }
          let yTiles: number = Math.floor((this.sceneHeight - this.barHeight) / ResourceManager.TILE_WIDTH);
          ResourceManager.BATTLE_FIELD_X = (this.sceneWidth - xTiles * ResourceManager.TILE_WIDTH) / 2;
          ResourceManager.BATTLE_FIELD_Y = this.sceneHeight - yTiles * ResourceManager.TILE_WIDTH - ResourceManager.BATTLE_FIELD_X;

          this.battleField = new BattleField(xTiles, yTiles, this.context);
          this.battleField.initBattlefield();

          Powerups.create();
          Powerups.setLayerManager(this.layerManager);
          Powerups.setBattleField(this.battleField);

          Tanks.create();
          Tanks.setBattleField(this.battleField);
          Tanks.setLayerManager(this.layerManager);

          Bullets.create();
          Bullets.setBattleField(this.battleField);
          Bullets.setLayerManager(this.layerManager);

          Explosions.create();
          Explosions.setLayerManager(this.layerManager);

          Scores.create();
          Scores.setLayerManager(this.layerManager);

          this.playerTank = Tanks.getPlayerTank();
          this.layerManager.append(this.battleField);
          this.totalLayers = this.layerManager.getSize();

          this.iconWidth = (this.sceneWidth - Resources.BATTLE_FIELD_X*2)/17;
          this.flagHeight = this.barHeight * .7;
          this.flagWidth = this.iconWidth * 2;
          this.enemyHeight = this.flagHeight /2;
          this.enemyWidth = this.iconWidth;
          this.playerHeight = this.enemyHeight;
          this.playerWidth = this.iconWidth;
          this.ipHeight = this.enemyHeight;
          this.ipWidth = this.iconWidth*2;
          this.marginY = this.barHeight * .2;
          this.marginX = Resources.BATTLE_FIELD_X;

          this.gameOverWidth = this.sceneWidth * .6;
          this.gameOverHeight = this.imgGameover.height * this.gameOverWidth / this.imgGameover.width ;
          this.gameStatus = new Sprite(this.imgGameover, this.imgGameover.width, this.imgGameover.height,
            this.gameOverWidth,this.gameOverHeight
          );
          this.gameStatus.setPosition((this.sceneWidth - this.gameStatus.getWidth()) / 2,this.sceneHeight);
          this.gameStatus.setBorder(Resources.SHOW_BORDER);
          this.gameStatus.setVisible(false);

          this.newGame();
        })
        .onReady(()=>{
          this.intervalID = setInterval(async () => {
            await this.run();
          }, 200)
        })
    }
    .height('100%')
    .width('100%')
    .onKeyEvent((e:KeyEvent)=>{
      if (e.type === KeyType.Down) {
        let gameAction: number = 0;
        if (this.isGameover) {
          return;
        }
        switch (e.keyCode) {
          case KeyCode.KEYCODE_2:
          case KeyCode.KEYCODE_DPAD_DOWN:
            gameAction = KeyCode.KEYCODE_DPAD_DOWN
            break;
          case KeyCode.KEYCODE_8:
          case KeyCode.KEYCODE_DPAD_UP:
            gameAction = KeyCode.KEYCODE_DPAD_UP
            break;
          case KeyCode.KEYCODE_4:
          case KeyCode.KEYCODE_DPAD_LEFT:
            gameAction = KeyCode.KEYCODE_DPAD_LEFT;
            break;
          case KeyCode.KEYCODE_6:
          case KeyCode.KEYCODE_DPAD_RIGHT:
            gameAction = KeyCode.KEYCODE_DPAD_RIGHT;
            break;
          case KeyCode.KEYCODE_5:
          case KeyCode.KEYCODE_SPACE:
          case KeyCode.KEYCODE_DPAD_CENTER:
            gameAction = KeyCode.KEYCODE_DPAD_CENTER;
            break;
          case KeyCode.KEYCODE_ENTER:
            // this.gameOver();
            break;
        }
        if (!this.isGameover) {
          this.playerTank!.keyPressed(gameAction);
        }
      } else {
        if (e.type === KeyType.Up) {
          let gameAction: number = 0;
          if (this.isGameover) {
            return;
          }
          switch (e.keyCode) {
            case KeyCode.KEYCODE_2:
            case KeyCode.KEYCODE_DPAD_UP:
              gameAction = KeyCode.KEYCODE_DPAD_UP;
              break;
            case KeyCode.KEYCODE_8:
            case KeyCode.KEYCODE_DPAD_DOWN:
              gameAction = KeyCode.KEYCODE_DPAD_DOWN;
              break;
            case KeyCode.KEYCODE_5:
            case KeyCode.KEYCODE_SPACE:
            case KeyCode.KEYCODE_ENTER:
            case KeyCode.KEYCODE_DPAD_CENTER:
              gameAction = KeyCode.KEYCODE_DPAD_CENTER;
              break;
            case KeyCode.KEYCODE_4:
            case KeyCode.KEYCODE_DPAD_LEFT:
              gameAction = KeyCode.KEYCODE_DPAD_LEFT;
              break;
            case KeyCode.KEYCODE_6:
            case KeyCode.KEYCODE_DPAD_RIGHT:
              gameAction = KeyCode.KEYCODE_DPAD_RIGHT;
              break;
            default:
              break;
          }
          if (!this.isGameover) {
            this.playerTank!.keyReleased(gameAction);
          }
        }
      }
    })
  }

  run() {
    this.tick();
    this.updateGame(this.context);
  }

  updateGame(g: CanvasRenderingContext2D) {
    this.clearBackground(g);
    // if(Resources.SHOW_GRID){
    //   this.drawGrid(g,this.battleField!.getXTiles(),this.battleField!.getYTiles());
    // }
    this.drawScoreBar(g);
    this.layerManager.paint(g)
    if(this.gameStatus!.isVisible()){
      this.gameStatus!.paint(g);
    }
  }

  drawScoreBar(g: CanvasRenderingContext2D) {
    let x: number = 0, y: number = 0;
    for (let i = 0; i < GameScene.enemyTankRemains - Tanks.getVisibleEnemyTanks(); i++) {
      let changeRow: number = i > 9 ? 1 : 0;
      x = this.marginX + (i % 10) * this.enemyWidth;
      y = this.marginY + changeRow * this.enemyHeight;
      g.drawImage(this.imgEnemyIcon, 0, 0, this.imgEnemyIcon.width, this.imgEnemyIcon.height,
        x, y, this.enemyWidth, this.enemyHeight
      );
    }
    //draw IP
    x = this.marginX + this.enemyWidth * 10.5;
    y = this.marginY;
    g.drawImage(this.imgIP, 0, 0,this.imgIP.width,this.imgIP.height,x,y,this.ipWidth,this.ipHeight);
    g.drawImage(this.imgPlayerIcon, 0, 0,this.imgPlayerIcon.width,this.imgPlayerIcon.height,x,y+this.playerHeight,this.playerWidth,this.playerHeight);
    let lives: number = this.playerTank!.getAvaiableLives();
    this.drawNumber(g, lives, x + this.playerWidth, y + this.playerHeight);

    x += this.ipWidth + this.enemyWidth * .5;
    y = this.marginY;
    g.drawImage(this.imgFlag, 0, 0,this.imgFlag.width,this.imgFlag.height,x,y,this.flagWidth,this.flagHeight);
    this.drawNumber(g, Resources.gameLevel, x + this.flagWidth, y + this.playerHeight);
  }

  drawNumber(g: CanvasRenderingContext2D, number: number, x: number, y: number) {
    let imageNumber: ImageBitmap = this.imgNumberBlack;
    let strNumber: string = number.toString();
    let srcWidth: number = imageNumber.width / 10;
    let srcHeight: number = imageNumber.height;

    for (let i = 0; i < strNumber.length; i++) {
      let ch: string = strNumber.charAt(i);
      let index: number = parseInt(ch);
      g.drawImage(imageNumber, index * srcWidth, 0, srcWidth, srcHeight, x + i * this.iconWidth, y, this.iconWidth, this.playerHeight);
    }
  }


  newGame(){
    if (Resources.isPlayingSound) {
      Resources.playSound(Resources.OPEN_SOUND);
    }
    this.playerTank!.initTank();
    this.playerTank!.setAvaiableLives(this.defaultPlayerLive);
    Tanks.explodeAllEnemies();
    Bullets.stopAllBullets();
    Explosions.stopAllExplosions();
    Powerups.removeAllPowerups();
    Powerups.putNewPowerup(Powerup.HOME);
    GameScene.enemyTankRemains = GameScene.TOTAL_ENEMY_TANKS;
    this.timeTaken = 0;
    GameScene.canPutPowerup = false;
    this.enemySpawnStartTime = 0;
    this.putPowerupStartTime = 0;
    this.gameOverStartTime = 0;
    this.gameStatus!.setVisible(false);
    if (this.isGameover) {
      this.playerTank!.setScore(0);
    }
    this.isGameover = false;
    for (let i = 0; i < 4; i++) {
      GameScene.enemyTanksCount[i] = 0;
    }
    try {
      //battleField.initBattlefield(this.getClass().getResourceAsStream(fileName));
      // this.battleField.readBattlefieldFromHZK(ResourceManager.gameLevels[ResourceManager.gameLevel]);
    } catch (e) {
      //inglore the exception.
    }

  }

  tick() {
    for (let i = 0; i < this.totalLayers; i++) {
      let layer: Layer = this.layerManager.getLayerAt(i);
      if (layer.isVisible()) {
        let actor: Actor = layer as Actor;
        actor.tick();
      }
    }
    this.applyGameLogic();
  }

  applyGameLogic(){
    let tickTime = Date.now();
    if(!this.isGameover){
      Powerups.checkPlayerTank(this.playerTank!);
      let canSpawnEnemyTank: boolean = false;
      let enemyTanks:number = Tanks.getVisibleEnemyTanks();
      if(GameScene.enemyTankRemains - enemyTanks > 0){
        if (enemyTanks < 10){
          if (this.enemySpawnStartTime > 0){
            if(tickTime - this.enemySpawnStartTime > this.enemySpawnPeriod){
              canSpawnEnemyTank = true;
            }
          }else{
            canSpawnEnemyTank = true;
          }
        }
      }else{
        if (Tanks.getVisibleEnemyTanks() == 0) {
          Resources.gameLevel++;
          router.pushUrl({ url: 'screen/ScoreScreen' })
        }
      }
      if(canSpawnEnemyTank){
        let enemyTank: EnemyTank | null = null;
        let tankSelection = Math.floor(Math.abs(Math.random() * 110) % 100);
        if (tankSelection > 90 - Resources.gameLevel) {
          enemyTank = Tanks.newEnemyTank(Tanks.TYPE_HEAVY);
        } else if (tankSelection > 75 - Resources.gameLevel) {
          enemyTank = Tanks.newEnemyTank(Tanks.TYPE_SMART);
        } else if (tankSelection > 55 - Resources.gameLevel) {
          enemyTank = Tanks.newEnemyTank(Tanks.TYPE_FAST);
        } else {
          enemyTank = Tanks.newEnemyTank(Tanks.TYPE_SIMPLE);
        }
        if (enemyTank != null) {
          enemyTank!.setDirection(BattleField.SOUTH)
          tankSelection = Math.floor(Math.abs(Math.random() * 110) % 100);
          if (tankSelection + Resources.gameLevel > 90) {
            enemyTank.setHasPrize(true);
          }
        }
        this.enemySpawnStartTime = tickTime;
      }

      //Check if player has been killed
      if (!this.playerTank!.isVisible()) {
        if (this.playerTank!.getAvaiableLives() > 0) {
          this.playerTank!.initTank();
          this.playerTank!.setVisible(true);
        } else {
          this.gameOver();
        }
      }

      if (Powerups.isHomeDestroyed()) {
        this.gameOver();
      }
      //put an poweup in the battle field
      if ((tickTime - this.putPowerupStartTime > this.putPowerupPeriod) || GameScene.canPutPowerup) {
        this.putAnPowerup();
      }
    }else{
      if (((tickTime - this.gameOverStartTime) < this.gameOverPeriod) && this.gameOverStartTime > 0) {
        let finalY: number = (this.sceneHeight - this.gameStatus!.getHeight()  - this.barHeight) / 2 ;
        if (this.gameStatus!.getY() > finalY) {
          this.gameStatus!.setPosition(this.gameStatus!.getX(), this.gameStatus!.getY() - 20);
        }
      } else {
        clearInterval(this.intervalID)
        this.gameOverStartTime = 0;
        setTimeout(()=>{
          router.pushUrl({ url: 'screen/ScoreScreen' })
        },5000)
      }
    }
  }

  putAnPowerup() {
    let powupSelection = Math.abs(Math.random() * 101) % 100;
    let type = Powerup.STAR;
    if (powupSelection > 95) {
      type = Powerup.TANK;
    } else if (powupSelection > 80) {
      type = Powerup.BOMB;
    } else if (powupSelection > 70) {
      type = Powerup.SHOVEL;
    } else if (powupSelection > 60) {
      type = Powerup.CLOCK;
    } else if (powupSelection > 50) {
      type = Powerup.SHIELD;
    } else {
      type = Powerup.STAR;
    }
    Powerups.putNewPowerup(type);
    this.putPowerupStartTime = Date.now();
    GameScene.canPutPowerup = false;
  }

  clearBackground(g:CanvasRenderingContext2D){
    g.fillStyle = '#808080'
    g.fillRect(0, 0, this.sceneWidth, this.sceneHeight)
    g.fillStyle = '#000000'
    g.fillRect(ResourceManager.BATTLE_FIELD_X, ResourceManager.BATTLE_FIELD_Y,
      this.battleField!.getWidth(), this.battleField!.getHeight()
    )
  }

  drawGrid(g:CanvasRenderingContext2D,xtiles:number,ytiles:number){
    g.lineWidth=3
    g.strokeStyle = '#FF0000'
    for(let i=1;i< xtiles;i++){
      g.beginPath()
      g.moveTo(Resources.BATTLE_FIELD_X + i * Resources.TILE_WIDTH,Resources.BATTLE_FIELD_Y)
      g.lineTo(Resources.BATTLE_FIELD_X + i * Resources.TILE_WIDTH,Resources.BATTLE_FIELD_Y+this.battleField!.getHeight())
      g.stroke()
    }

    for(let i=1;i< ytiles;i++){
      g.beginPath()
      g.moveTo(Resources.BATTLE_FIELD_X ,Resources.BATTLE_FIELD_Y+ i * Resources.TILE_WIDTH)
      g.lineTo(Resources.BATTLE_FIELD_X + this.battleField!.getWidth(),Resources.BATTLE_FIELD_Y+ i * Resources.TILE_WIDTH)
      g.stroke()
    }

    g.lineWidth=1
    g.strokeStyle = '#00FF00'

    for(let i=0;i< xtiles;i++){
      g.beginPath()
      g.moveTo(Resources.BATTLE_FIELD_X + (i+0.5) * Resources.TILE_WIDTH ,Resources.BATTLE_FIELD_Y)
      g.lineTo(Resources.BATTLE_FIELD_X + (i+0.5) * Resources.TILE_WIDTH,Resources.BATTLE_FIELD_Y+this.battleField!.getHeight())
      g.stroke()
    }

    for(let i=0;i< ytiles;i++){
      g.beginPath()
      g.moveTo(Resources.BATTLE_FIELD_X ,Resources.BATTLE_FIELD_Y+ (i+0.5) * Resources.TILE_WIDTH)
      g.lineTo(Resources.BATTLE_FIELD_X + this.battleField!.getWidth(),Resources.BATTLE_FIELD_Y+ (i+0.5) * Resources.TILE_WIDTH)
      g.stroke()
    }

  }

  gameOver() {
    this.isGameover = true;
    this.gameStatus!.setVisible(true);
    this.playerTank!.stop();
    this.gameOverStartTime = Date.now();
  }


}