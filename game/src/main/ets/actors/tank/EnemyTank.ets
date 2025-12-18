import Resources from "../../Resources";
import { GameScene } from "../../screen/GameScene";
import { Bullet } from "../actor/Bullet";
import { BattleField } from "../BattleField";
import { Bullets } from "../Bullets";
import { Scores } from "../Scores";
import { Tanks } from "../Tanks";
import { Tank } from "./Tank";

export abstract  class EnemyTank extends  Tank{
  private hasPrize: boolean = false;
  private score: number = 0;
  private blood: number = 1;
  private status: number = 0;

  private switchImage: boolean = false;
  private startShootingTime: number = 0;
  private immobilizedStartTime: number = 0;
  private minimumShootingPeriod: number = 4000;
  private immobilizedPeriod: number = 30000;

  constructor(hasPrize: boolean) {
    let img: ImageBitmap = Resources.getImage(Resources.ENEMY);
    super(img, img.width / 23, img.height / 4);
    this.hasPrize = hasPrize;
    this.setSpeed(Resources.TILE_WIDTH / 6)
    this.setFrame(22);
    this.setVisible(false);
  }

  initTank() {
    this.status = Tanks.STATUS_NEW_BORN;
    switch (this.getType()) {
      case Tanks.TYPE_SIMPLE:
      case Tanks.TYPE_SMART:
        this.setSpeed(Resources.TILE_WIDTH / 6);
        this.blood = 1;
        break;
      case Tanks.TYPE_FAST:
        this.blood = 1;
        this.setSpeed( Resources.TILE_WIDTH / 2);
        break;
      case Tanks.TYPE_HEAVY:
        this.setSpeed(Resources.TILE_WIDTH / 6);
        this.blood = 4;
        break;
    }
  }

  think(): void {
    this.changeDirection(this.getDirection());
    if (this.getDirection() != BattleField.NONE) {
      this.setTankFrame();
    }
  }

  tick(): void {
    super.tick();
  }

  setTankFrame() {
    this.switchImage = !this.switchImage;
    let offset = this.switchImage ? 0 : 1;
    let offset1 = this.hasPrize ? 2 : 0;
    let frame = this.getDirection() * 23 + offset + offset1 + this.getType() * 4 + (this.blood - 1) * 2;
    if (this.getType() == Tanks.TYPE_HEAVY && this.hasPrize) {
      frame = this.getDirection() * 23 + offset + this.getType() * 4 + 8;
    }
    try {
      if (frame >= 0 || frame < 92) {
        this.setFrame(frame);
      }
    } catch (e) {
      //System.out.println("enemy:"+frame+","+blood);
    }
  }

  shoot(): Bullet | null {
    let bullet: Bullet | null = null;
    let tickTime = Date.now();
    let canShoot: boolean = (tickTime - this.startShootingTime) > this.minimumShootingPeriod;
    canShoot &&= this.getDirection() != BattleField.NONE;
    if (this.isShooting() && canShoot) {
      this.startShootingTime = tickTime;
      bullet = Bullets.getFreeBullet();
      if (bullet != null) {
        let x = this.getX()+this.getWidth()/2-bullet.getWidth()/2;
        let y = this.getY()+this.getHeight()/2-bullet.getHeight()/2;
        bullet.setSpeed(Resources.TILE_WIDTH / 2);
        bullet.setDirection(this.getDirection());
        if (this.getType() == Tanks.TYPE_HEAVY) {
          bullet.setStrength(Bullet.GRADE_BREAK_CONCRETE_WALL);
        } else {
          bullet.setStrength(Bullet.GRADE_DEFAULT);
        }
        bullet.setPosition(x, y);
        bullet.setFriendly(false);
        bullet.setVisible(true);
      }
    }
    return bullet;
  }

  explode() {
    if (this.getType() == Tanks.TYPE_HEAVY && this.hasPrize && this.blood == 4) {
      GameScene.canPutPowerup = true;
      this.hasPrize = false;
    }
    this.blood--;
    if (this.blood == 0) {
      super.explode();
      Scores.show(this.getX(), this.getY(), this.score);
      GameScene.enemyTankRemains--;
      if (this.hasPrize) {
        GameScene.canPutPowerup = true;
      }
      GameScene.enemyTanksCount[this.getType()]++;
    }
  }

  setImmobilizedStartTime(time:number){
    this.immobilizedStartTime = time;
  }

  setBlood(blood:number){
    this.blood = blood;
  }

  getBlood():number{
    return this.blood;
  }

  setHasPrize(hasPrize:boolean){
    this.hasPrize = hasPrize;
  }

  isHasPrize():boolean{
    return this.hasPrize;
  }

  setScore(score:number){
    this.score = score;
  }

  getScore():number{
    return this.score;
  }

}