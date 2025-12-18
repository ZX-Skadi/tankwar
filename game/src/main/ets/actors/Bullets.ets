import { LayerManager } from "@ohos/core";
import { Bullet } from "./actor/Bullet";
import { BattleField } from "./BattleField";

export class Bullets {
  public static BULLETS: Bullet[] = [];
  public static POOL_SIZE: number = 20;

  public static create() {
    for (let i = 0; i < Bullets.POOL_SIZE; i++) {
      Bullets.BULLETS.push(new Bullet(Bullet.GRADE_DEFAULT, BattleField.NONE, 0));
      Bullets.BULLETS[i].setVisible(false);
    }
  }

  public static setLayerManager(manager: LayerManager) {
    if (manager != null) {
      for (let i = 0; i < Bullets.BULLETS.length; i++){
        manager.append(Bullets.BULLETS[i]);
      }
    }
  }

  public static setBattleField(field: BattleField) {
    if (field != null) {
      for (let i = 0; i < Bullets.BULLETS.length; i++){
        Bullets.BULLETS[i].setBattleField(field);
      }
    }
  }

  public static getPlayerBulletCount(): number {
    let count: number = 0;
    for (let i = 0; i < Bullets.BULLETS.length; i++) {
      if (Bullets.BULLETS[i].isVisible() && Bullets.BULLETS[i].isFriendly()) {
        count++;
      }
    }
    return count;
  }

  public static stopAllBullets() {
    for (let i = 0; i < Bullets.BULLETS.length; ++i) {
      if (!Bullets.BULLETS[i].isFriendly()) {
        Bullets.BULLETS[i].setVisible(false);
      }
    }
  }

  public static getFreeBullet(): Bullet | null {
    for (let i = 0; i < Bullets.BULLETS.length; i++) {
      if (!Bullets.BULLETS[i].isVisible()) {
        Bullets.BULLETS[i].setVisible(true);
        return Bullets.BULLETS[i];
      }
    }
    return null;
  }

}
