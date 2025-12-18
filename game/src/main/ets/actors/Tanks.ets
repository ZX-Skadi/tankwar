import { LayerManager, Sprite } from "@ohos/core";
import Resources from "../Resources";
import { BattleField } from "./BattleField";
import { EnemyTank } from "./tank/EnemyTank";
import { FastTank } from "./tank/FastTank";
import { HeavyTank } from "./tank/HeavyTank";
import { PlayerTank } from "./tank/PlayerTank";
import { SimpleTank } from "./tank/SimpleTank";
import { SmartTank } from "./tank/SmartTank";
import { Tank } from "./tank/Tank";

export class Tanks {
  public static TANKS: Tank[] = [];
  public static TYPE_SIMPLE: number = 0;
  public static TYPE_FAST: number = 1;
  public static TYPE_SMART: number = 2;
  public static TYPE_HEAVY: number = 3;
  public static STATUS_NEW_BORN: number = 0;
  public static STATUS_LIVE: number = 1;
  public static STATUS_DEAD: number = 2;
  public static DEFAULT_SPEED: number = Resources.TILE_WIDTH / 4;

  public static create() {
    //player tank
    Tanks.TANKS.push(new PlayerTank());
    //max 7 simple tanks
    for (let i = 1; i < 8; i++) {
      Tanks.TANKS.push(new SimpleTank(false));
    }
    //max 4 fast tanks
    for (let i = 8; i < 12; i++) {
      Tanks.TANKS.push(new FastTank(false));
    }
    //max 4 smart tanks
    for (let i = 12; i < 16; i++) {
      Tanks.TANKS.push(new SmartTank(false));
    }
    //max 4 heavy tanks
    for (let i = 16; i < 21; i++) {
      Tanks.TANKS.push(new HeavyTank(false));
    }
  }

  public static setLayerManager(manager: LayerManager) {
    if (manager != null) {
      for (let i = 0; i < Tanks.TANKS.length; i++) {
        Tanks.TANKS[i].setLayerManager(manager);
        manager.append(Tanks.TANKS[i]);
      }
    }
  }

  public static setBattleField(field: BattleField) {
    if (field != null) {
      for (let i = 0; i < Tanks.TANKS.length; i++) {
        Tanks.TANKS[i].setBattleField(field);
      }
    }
  }

  public static getPlayerTank(): PlayerTank {
    return Tanks.TANKS[0] as PlayerTank;
  }

  public static getVisibleEnemyTanks(): number {
    let count = 0;
    for (let i = 1; i < Tanks.TANKS.length; i++) {
      if (Tanks.TANKS[i].isVisible()) {
        count++;
      }
    }
    return count;
  }


  public static newEnemyTank(type: number): EnemyTank | null {
    let enemyTank: EnemyTank | null = Tanks.getFreeEnemyTank(type);
    if (enemyTank != null) {
      enemyTank.initTank();
      enemyTank.setVisible(true);
    }
    return enemyTank;
  }

  public static getFreeEnemyTank(type: number): EnemyTank | null {
    let enemyTank: EnemyTank | null = null;
    let left = 0, right = 0;
    switch (type) {
      case Tanks.TYPE_SIMPLE:
        left = 1;
        right = 7;
        break;
      case Tanks.TYPE_FAST:
        left = 8;
        right = 11;
        break;
      case Tanks.TYPE_SMART:
        left = 12;
        right = 15;
        break;
      case Tanks.TYPE_HEAVY:
        left = 16;
        right = 19;
        break;
    }
    for (let i = left; i <= right; i++) {
      enemyTank = Tanks.TANKS[i] as EnemyTank;
      if (!enemyTank.isVisible()) {
        enemyTank.getBattleField()!.initEnemyTankPos(enemyTank);
        enemyTank.setVisible(true);
        if (Tanks.overlapsTank(enemyTank)) {
          enemyTank.setVisible(false);
          enemyTank = null;
          continue;
        }
        return enemyTank;
      }
    }
    return null;
  }

  public static overlapsTank(sprite: Sprite): boolean {
    for (let i = 0; i < Tanks.TANKS.length; i++) {
      if (sprite != Tanks.TANKS[i] && Tanks.TANKS[i].isVisible() && sprite.collidesWithSprite(Tanks.TANKS[i])) {
        return true;
      }
    }
    return false;
  }

  public static getTank(i: number): Tank | null {
    if (i > Tanks.TANKS.length - 1) {
      return null;
    }
    if (Tanks.TANKS[i] != null) {
      return Tanks.TANKS[i];
    } else {
      return null;
    }
  }

  public static explodeAllEnemies() {
    for (let i = 1; i < Tanks.TANKS.length; ++i) {
      let tank: EnemyTank = Tanks.TANKS[i] as EnemyTank;
      if (tank.isVisible()) {
        tank.setBlood(1);
        tank.explode();
      }
      tank.setImmobilizedStartTime(0)
    }
  }


}