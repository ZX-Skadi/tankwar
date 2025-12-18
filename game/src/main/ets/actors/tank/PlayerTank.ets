import Resources from "../../Resources";
import { Tank } from "./Tank";
import { KeyCode } from "@kit.InputKit";
import { BattleField } from "../BattleField";
import { Tanks } from "../Tanks";
import { Bullet } from "../actor/Bullet";
import { Bullets } from "../Bullets";
import { Powerup } from "../actor/Powerup";
import { Powerups } from "../Powerups";

export class PlayerTank extends Tank {
  private avaiableLife: number = 3;
  private MIN_GRADE: number = 1;
  private GRADE_TWO_BULLETS: number = 2;
  private GRADE_THREE_BULLETS: number = 3;
  private GRADE_BREAK_CONCRETE_WALL: number = 4;
  private GRADE_BREAK_WATER: number = 5;
  private GRADE_SHELL_1: number = 6;
  private GRADE_SPEED: number = 7;
  private GRADE_SHELL_2: number = 8;
  private MAX_GRADE: number = 8;
  private NEW_BORN: number = 9;
  private grade: number = this.MIN_GRADE;
  private avaiableBullets: number = 1;
  private sheild: Powerup | null = null;
  private score: number = 0;
  private currentDirection: number = BattleField.NONE;
  private invulnerabilityTicks: number = 0;
  private invulnerableTime: number = 0;
  private invulnerablePeriod: number = 30000;
  private switchImage: boolean = false;
  private immobilizedStartTime: number = 0;
  private keyPressTimerId:number = 0;
  private isKeyRelease:boolean = false;

  constructor() {
    let img: ImageBitmap = Resources.getImage(Resources.PLAYER);
    super(img, img.width / 9, img.height / 4);
    this.setSpeed(Resources.TILE_WIDTH/4);
    this.sheild = Powerups.getInvulnerable();
  }

  initTank() {
    if (this.getBattleField() != null) {
      this.getBattleField()!.initPlayerTankPos(this);
      this.setVisible(true);
      this.setDirection(BattleField.NONE);
      this.grade = this.NEW_BORN;
      this.setNewBornTimer(0);
      this.avaiableBullets = 1;
      this.setSpeed(Tanks.DEFAULT_SPEED);
      this.setShooting(false);
    }
  }

  setAvaiableLives(live: number) {
    this.avaiableLife = live;
  }

  getAvaiableLives(): number {
    return this.avaiableLife;
  }

  addScore(value: number) {
    this.score += value;
  }

  setScore(value: number) {
    this.score = value;
  }

  getScore() {
    return this.score;
  }

  public keyPressed(gameAction: number) {
    if (gameAction == KeyCode.KEYCODE_DPAD_UP) {
      this.setDirection(BattleField.NORTH);
    } else if (gameAction == KeyCode.KEYCODE_DPAD_RIGHT) {
      this.setDirection(BattleField.EAST);
    } else if (gameAction == KeyCode.KEYCODE_DPAD_LEFT) {
      this.setDirection(BattleField.WEST);
    } else if (gameAction == KeyCode.KEYCODE_DPAD_DOWN) {
      this.setDirection(BattleField.SOUTH);
    } else if (gameAction == KeyCode.KEYCODE_DPAD_CENTER) {
      this.setShooting(true);
    }
    if (this.getDirection() != BattleField.NONE) {
      this.currentDirection = this.getDirection();
    }
    if(this.isKeyRelease){
      this.isKeyRelease = false;
    }
  }

  keyReleased(gameAction: number) {
    if(!this.isKeyRelease){
      this.keyPressTimerId = setInterval(async () => {
        this.setDirection(BattleField.NONE);
        clearInterval(this.keyPressTimerId);
        this.isKeyRelease = true;
      }, 2000)

    }
  }

  think(): void {
    if (this.grade == this.NEW_BORN) {
      this.setNewBornTimer(this.getNewBornTimer()+1)
      if (this.getNewBornTimer() > 4) {
        this.grade = this.MIN_GRADE;
        this.setDirection(BattleField.NONE);
        this.currentDirection = BattleField.NORTH;
        this.setNewBornTimer( 0);
        this.setFrame(0);
        this.invulnerableTime = Date.now();
        this.invulnerabilityTicks = this.invulnerablePeriod / 4;
        this.sheild!.setPosition(this.getX(), this.getY());
        this.sheild!.setVisible(true);
      } else {
        try {
          this.setFrame(this.getNewBornTimer() * 9 - 1);
        } catch (e) {
          //System.out.println("Playertank");
        }
      }
    } else {
      let tickTime = Date.now();
      if (tickTime - this.invulnerableTime > this.invulnerabilityTicks) {
        this.sheild!.setVisible(false);
      } else {
        this.sheild!.setPosition(this.getX(), this.getY());
        this.sheild!.setVisible(true);
      }
      this.changeDirection(this.getDirection());
      if (this.currentDirection != BattleField.NONE) {
        this.switchImage = !this.switchImage;
        let offset: number = this.switchImage ? 0 : 1;
        try {
          this.setFrame(this.currentDirection * 9 + Math.floor((this.grade - 1) / 2) * 2 + offset);
        } catch (e) {
          //System.out.println("Playertank1");
        }
      }
    }

  }

  shoot(): Bullet | null {
    let bullet: Bullet | null = null;
    let bulletCount = Bullets.getPlayerBulletCount();
    if (this.isShooting() && bulletCount < this.avaiableBullets) {
      this.setShooting( false);
      this.setDirection( BattleField.NONE);
      bullet = Bullets.getFreeBullet();
      if (bullet != null) {
        if(Resources.isPlayingSound){
          Resources.playSound(Resources.SHOOT_SOUND);
        }
        let x = this.getX()+this.getWidth()/2-bullet.getWidth()/2;
        let y = this.getY()+this.getHeight()/2-bullet.getHeight()/2;
        bullet.setSpeed(Resources.TILE_WIDTH / 2);
        bullet.setDirection(this.currentDirection);
        if (this.grade >= this.GRADE_BREAK_WATER) {
          bullet.setStrength(Bullet.GRADE_BREAK_WATER);
        } else if (this.grade >= this.GRADE_BREAK_CONCRETE_WALL) {
          bullet.setStrength(Bullet.GRADE_BREAK_CONCRETE_WALL);
        } else {
          bullet.setStrength(Bullet.GRADE_DEFAULT);
        }
        bullet.setPosition(x , y);
        bullet.setFriendly(true);
        bullet.setVisible(true);
      }
    }
    return bullet;
  }

  stop() {
    this.setDirection( BattleField.NONE);
    this.setShooting( false);
  }

  explode() {
    if (!this.isInvulnerable()) {
      if (this.grade >= this.GRADE_BREAK_WATER) {
        this.grade--;
      } else {
        this.avaiableLife--;
        this.setVisible(false)
        super.explode();
      }
    }
  }

  isInvulnerable(): boolean {
    return this.sheild!.isVisible();
  }

  upgrade(powerup: Powerup) {
    switch (powerup.getType()) {
      case Powerup.CLOCK:
        this.immobilizedStartTime = Date.now();
        break;
      case Powerup.STAR:
        this.grade++;
        if (this.grade > this.MAX_GRADE) {
          this.grade = this.MAX_GRADE;
        }
        switch (this.grade) {
          case this.GRADE_SPEED:
            this.setSpeed(this.getSpeed()*2) ;
            let x = this.getX();
            let y = this.getY();
            x = Math.floor(x / this.getSpeed()) * this.getSpeed();
            y = Math.floor(y / this.getSpeed()) * this.getSpeed();
            this.setPosition(x, y);
            break;
          case this.GRADE_TWO_BULLETS:
            this.avaiableBullets = 2;
            break;
          case this.GRADE_THREE_BULLETS:
            this.avaiableBullets = 3;
            break;
        }
        break;
      case Powerup.SHIELD:
        this.invulnerableTime = Date.now();
        this.invulnerabilityTicks = this.invulnerablePeriod;
        this.sheild!.setPosition(this.getX(), this.getY());
        this.sheild!.setVisible(true);
        break;
      case Powerup.BOMB:
        Tanks.explodeAllEnemies();
        break;
      case Powerup.TANK:
        this.avaiableLife++;
        break;
      case Powerup.SHOVEL:
        this.getBattleField()!.makeHomeConcreteWall();
        break;
    }
  }


}