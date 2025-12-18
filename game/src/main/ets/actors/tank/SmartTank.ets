import Resources from "../../Resources";
import { Score } from "../actor/Score";
import { BattleField } from "../BattleField";
import { Tanks } from "../Tanks";
import { EnemyTank } from "./EnemyTank";
import { PlayerTank } from "./PlayerTank";

export class SmartTank extends EnemyTank {
  constructor(hasPrize: boolean) {
    super(hasPrize);
    this.setDirection(BattleField.SOUTH);
    this.setSpeed(Resources.TILE_WIDTH / 2);
    this.setType(Tanks.TYPE_SMART);
    this.setScore(Score.SCORE_200)
  }

  private dist(a:number,b:number):number{
    return a*a + b*b;
  }

  think() {
    let playerTank: PlayerTank = Tanks.TANKS[0] as PlayerTank;
    let newdir: number = BattleField.SOUTH;
    let minDistance: number = Infinity;
    let distance: number = 0;

    let blockedeast: boolean = this.getBattleField()!.containsImpassableArea(
      this.getX() + this.getSpeed(), this.getY(), this.getWidth(), this.getHeight()
    );
    let blockedsouth: boolean = this.getBattleField()!.containsImpassableArea(
      this.getX(), this.getY() + this.getSpeed(), this.getWidth(), this.getHeight()
    );
    let blockedwest: boolean = this.getBattleField()!.containsImpassableArea(
      this.getX() - this.getSpeed(), this.getY(), this.getWidth(), this.getHeight()
    );
    let blockednorth: boolean = this.getBattleField()!.containsImpassableArea(
      this.getX(), this.getY() - this.getSpeed(), this.getWidth(), this.getHeight()
    );
    if (this.getDirection() == BattleField.NORTH) {
      if (!blockedwest) {
        distance = this.dist(this.getX() - this.getSpeed() - playerTank.getX(), this.getY() - playerTank.getY())
        if (distance < minDistance) {
          newdir = BattleField.WEST;
          minDistance = distance;
        }
      }
      if (!blockedeast) {
        distance = this.dist(this.getX() + this.getSpeed() - playerTank.getX(), this.getY() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.EAST;
          minDistance = distance;
        }
      }
      if (!blockednorth) {
        distance = this.dist(this.getX() - playerTank.getX(), this.getY() - this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.NORTH;
          minDistance = distance;
        }
      }
      distance = this.dist(this.getX() - playerTank.getX(), this.getY() - playerTank.getY());
      if (distance < minDistance) {
        newdir = BattleField.NONE;
        minDistance = distance;
      }
    } else if (this.getDirection() == BattleField.WEST) {
      if (!blockedwest) {
        distance = this.dist(this.getX() - this.getSpeed() - playerTank.getX(), this.getY() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.WEST;
          minDistance = distance;
        }
      }
      if (!blockedsouth) {
        distance = this.dist(this.getX() - playerTank.getX(),this.getY() + this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.SOUTH;
          minDistance = distance;
        }
      }
      if (!blockednorth) {
        distance = this.dist(this.getX() - playerTank.getX(),this.getY() - this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.NORTH;
          minDistance = distance;
        }
      }
      distance = this.dist(this.getX() - playerTank.getX(),this.getY() - playerTank.getY());
      if (distance < minDistance) {
        newdir = BattleField.NONE;
        minDistance = distance;
      }
    } else if (this.getDirection() == BattleField.SOUTH) {
      if (!blockedwest) {
        distance = this.dist(this.getX() - this.getSpeed() - playerTank.getX(),this.getY() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.WEST;
          minDistance = distance;
        }
      }
      if (!blockedsouth) {
        distance = this.dist(this.getX() - playerTank.getX(),this.getY() + this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.SOUTH;
          minDistance = distance;
        }
      }
      if (!blockedeast) {
        distance = this.dist(this.getX() + this.getSpeed() - playerTank.getX(),this.getY() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.EAST;
          minDistance = distance;
        }
      }
      distance = this.dist(this.getX() - playerTank.getX(),this.getY() - playerTank.getY());
      if (distance < minDistance) {
        newdir = BattleField.NONE;
        minDistance = distance;
      }
    } else if (this.getDirection() == BattleField.EAST) {
      if (!blockednorth) {
        distance = this.dist(this.getX() - playerTank.getX(),this.getY() - this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.NORTH;
          minDistance = distance;
        }
      }
      if (!blockedsouth) {
        distance = this.dist(this.getX() - playerTank.getX(),this.getY() + this.getSpeed() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.SOUTH;
          minDistance = distance;
        }
      }

      if (!blockedeast) {
        distance = this.dist(this.getX() + this.getSpeed() - playerTank.getX(),this.getY() - playerTank.getY());
        if (distance < minDistance) {
          newdir = BattleField.EAST;
          minDistance = distance;
        }
      }
      distance = this.dist(this.getX() - playerTank.getX(),this.getY() - playerTank.getY());
      if (distance < minDistance) {
        newdir = BattleField.NONE;
        minDistance = distance;
      }
    } else {
      if (Math.floor(Math.abs(Math.random() * 11) % 10) > 5) {
        newdir = Math.floor(Math.abs(Math.random() * 5) % 4);
      }
    }
    this.changeDirection(newdir);

    this.setShooting(false) ;
    let shoot: number = Math.floor(Math.abs(Math.random() * 110) % 100);
    if (shoot >= 50 || this.lookforPlayer(this.getDirection())) {
      this.setShooting(true);
    }
    super.think();
  }

  lookforPlayer(dir: number): boolean {
    let playerTank: PlayerTank = Tanks.TANKS[0] as PlayerTank;
    let playerX: number = playerTank.getX();
    let playerY: number = playerTank.getY();
    let dx: number = 0;
    let dy: number = 0;
    if (dir == BattleField.NORTH) {
      dy = -this.getSpeed();
    } else if (dir == BattleField.SOUTH) {
      dy = this.getSpeed();
    } else if (dir == BattleField.EAST) {
      dx = this.getSpeed();
    } else if (dir == BattleField.WEST) {
      dx = -this.getSpeed();
    } else {
      return false;
    }
    let myx: number = this.getX();
    let myy: number = this.getY();
    let width: number = this.getBattleField()!.getWidth();
    let height: number = this.getBattleField()!.getHeight();
    while (myx > 0 && myx < width && myy > 0 && myy < height) {
      //if(battleField.hitWall(myx,myy,0)){return false;}
      if (myx > playerX - this.getSpeed()
        && myx < playerX + this.getSpeed()
        && myy > playerY - this.getSpeed()
        && myy < playerY + this.getSpeed()
      ) {
        return true;
      }
      myx += dx;
      myy += dy;
    }
    return false;
  }


}