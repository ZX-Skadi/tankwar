import { LayerManager, Sprite } from "@ohos/core";
import Resources from "../../Resources";
import { Actor } from "../Actor";
import { BattleField } from "../BattleField";
import { Bullets } from "../Bullets";
import { Explosions } from "../Explosions";
import { Powerups } from "../Powerups";
import { EnemyTank } from "../tank/EnemyTank";
import { PlayerTank } from "../tank/PlayerTank";
import { Tanks } from "../Tanks";
import { Explosion } from "./Explosion";

export class Bullet extends Sprite implements Actor {
  public static GRADE_DEFAULT: number = 1;
  public static GRADE_BREAK_CONCRETE_WALL: number = 2;
  public static GRADE_BREAK_WATER: number = 3;

  private strength: number = Bullet.GRADE_DEFAULT;
  private friendly: boolean = false;
  private dx: number = 0;
  private dy: number = 0;

  private battleField: BattleField|null|undefined;

  constructor(strength: number, direction: number, speed: number) {
    let img: ImageBitmap = Resources.getImage(Resources.BULLET);
    super(img,img.width/ 4, img.height,Resources.TILE_WIDTH/4,Resources.TILE_WIDTH/4);
    super.setBorder(Resources.SHOW_BORDER);
    this.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y);
    this.strength = strength;
    this.setDirection(direction) ;
    this.setSpeed(speed)
  }

  tick() {
    if (!this.isVisible() || this.getDirection() == BattleField.NONE) {
      return;
    }
    // Move the bullet.
    this.move(this.dx, this.dy);
    let x = this.getX();
    let y = this.getY();
    let playerTank:PlayerTank =  Tanks.getPlayerTank() as PlayerTank;
    //outside the battle field, hitting the border
    if (x <= 0 || x >= this.battleField!.getWidth() || y <= 0  || y >= this.battleField!.getHeight()) {
      //this is to avoid explosition outside the battlefield.
      if (x <= 0) x = 0;
      if (x >= this.battleField!.getWidth()) x = this.battleField!.getWidth();
      if (y <= 0) y = 0;
      if (y >= this.battleField!.getHeight()) y = this.battleField!.getHeight();
      this.setPosition(x, y);
      this.explode();
      return;
    }

    // See if it hit a tank.
    if (this.friendly) {
      // See if it hit an enemy tank.
      for (let i = 1; i < Tanks.TANKS.length; i++) {
        let enemy:EnemyTank = Tanks.getTank(i) as EnemyTank;
        if (enemy != null && enemy.isVisible() && this.collidesWithSprite(enemy)) {
          enemy.explode();
          this.explode();
          return;
        }
      }
    } else {
      // See if it hit player tank.
      if (this.collidesWithSprite(playerTank)) {
        playerTank.explode();
        this.explode();
        return;
      }
    }

    //check to see if hit player's home
    if (Powerups.isHittingHome(this)) {
      //TODO: Game Over
      this.explode();
      return;
    }
    // See if it hit a wall.
    if (this.battleField!.hitWall(x, y, this.strength)) {
      this.explode();
      return;
    }

    // See if it hit another bullet.
    for (let i = 0; i < Bullets.BULLETS.length; i++) {
      let anotherBullet:Bullet = Bullets.BULLETS[i];
      if (this != anotherBullet && anotherBullet.isVisible()) {
        if (this.collidesWithSprite(anotherBullet)) {
          this.explode();
          Bullets.BULLETS[i].explode();
          return;
        }
      }
    }
  }


  setFriendly(friend: boolean) {
    this.friendly = friend;
  }

  isFriendly():boolean{
    return this.friendly
  }

  setDirection(direction: number) {
    if (direction == BattleField.NONE) {
      return;
    }
    super.setDirection(direction);
    this.setFrame(direction);
    switch (direction) {
      case BattleField.NORTH:
        this.dx = 0;
        this.dy = -this.getSpeed();
        break;
      case BattleField.EAST:
        this.dx = this.getSpeed();
        this.dy = 0;
        break;
      case BattleField.SOUTH:
        this.dx = 0;
        this.dy = this.getSpeed();
        break;
      case BattleField.WEST:
        this.dx = -this.getSpeed();
        this.dy = 0;
        break;
    }
  }

  setStrength(strength: number) {
    this.strength = strength;
  }

  explode() {
    this.setVisible(false);
    let x = this.getX() - Resources.TILE_WIDTH/2 + this.getWidth()/2;
    let y = this.getY() - Resources.TILE_WIDTH/2 + this.getHeight()/2;
    Explosions.explode(x, y, Explosion.SMALL);
  }

  setBattleField(field: BattleField) {
    this.battleField = field;
  }

}

