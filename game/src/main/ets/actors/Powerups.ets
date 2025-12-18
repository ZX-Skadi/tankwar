import { LayerManager } from "@ohos/core";
import { Bullet } from "./actor/Bullet";
import { Powerup } from "./actor/Powerup";
import { Score } from "./actor/Score";
import { BattleField } from "./BattleField";
import { Scores } from "./Scores";
import { PlayerTank } from "./tank/PlayerTank";

export class Powerups {
  public static POWERUPS: Powerup[] = [];
  public static POOL_SIZE: number = 10;

  public static create() {
    for (let i = 0; i < Powerups.POOL_SIZE; i++) {
      Powerups.POWERUPS.push(new Powerup(Powerup.NOTHING));
      Powerups.POWERUPS[i].setVisible(false);
    }
    Powerups.POWERUPS[0].setType(Powerup.INVULNERABLE);
  }

  public static setLayerManager(manager: LayerManager) {
    if (manager != null) {
      for (let i = 0; i < Powerups.POWERUPS.length; i++) {
        Powerups.POWERUPS[i].setLayerManager(manager)
        manager.append(Powerups.POWERUPS[i]);
      }
    }
  }

  public static setBattleField(field: BattleField) {
    if (field != null) {
      for (let i = 0; i < Powerups.POWERUPS.length; i++) {
        Powerups.POWERUPS[i].setBattleField(field);
      }
    }
  }

  public static isHomeDestroyed(): boolean {
    let bRet: boolean = false;
    for (let i = 1; i < Powerups.POWERUPS.length; i++) {
      if (Powerups.POWERUPS[i].isVisible() && Powerups.POWERUPS[i].getType() == Powerup.HOME_DESTROYED) {
        bRet = true;
        break;
      }
    }
    return bRet;
  }

  public static putNewPowerup(type: number) {
    for (let i = 1; i < Powerups.POWERUPS.length; i++) {
      if (!Powerups.POWERUPS[i].isVisible()) {
        Powerups.POWERUPS[i].setType(type);
        Powerups.POWERUPS[i].getBattleField()!.initPowerupPos(Powerups.POWERUPS[i]);
        Powerups.POWERUPS[i].setVisible(true);
        Powerups.POWERUPS[i].setStartTime(Date.now());
        break;
      }
    }
  }

  public static checkPlayerTank(tank: PlayerTank) {
    let powerup: Powerup;
    for (let i = 1; i < Powerups.POWERUPS.length; i++) {
      if (Powerups.POWERUPS[i].isVisible()) {
        powerup = Powerups.POWERUPS[i];
        if (powerup.collidesWithSprite(tank)) {
          tank.upgrade(powerup);
          if (!(powerup.getType() == Powerup.HOME || powerup.getType() == Powerup.HOME_DESTROYED)) {
            powerup.setVisible(false);
            Scores.show(tank.getX(), tank.getY(), Score.SCORE_500);
            tank.addScore(500);
          }
        }
      }
    }
  }

  public static removeAllPowerups() {
    for (let i = 1; i < Powerups.POWERUPS.length; ++i) {
      let powerup: Powerup = Powerups.POWERUPS[i];
      powerup.setVisible(false);
    }
  }

  public static isHittingHome(bullet: Bullet): boolean {
    let bRet: boolean = false;
    let home: Powerup | null = null;
    for (let i = 1; i < Powerups.POWERUPS.length; i++) {
      if (Powerups.POWERUPS[i].isVisible() && Powerups.POWERUPS[i].getType() == Powerup.HOME) {
        home = Powerups.POWERUPS[i];
      }
    }
    if (home != null) {
      bRet = bullet.collidesWithSprite(home);
      if (bRet) {
        home.setType(Powerup.HOME_DESTROYED);
      }
    }
    return bRet;
  }

  static getInvulnerable(): Powerup {
    return Powerups.POWERUPS[0];
  }


}
