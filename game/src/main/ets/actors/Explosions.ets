import { LayerManager } from "@ohos/core";
import Resources from "../Resources";
import { Explosion } from "./actor/Explosion";

export class Explosions {
  public static EXPLOSIONS: Explosion[] = [];
  public static POOL_SIZE = 10;

  public static create() {
    for (let i = 0; i < Explosions.POOL_SIZE; ++i) {
      Explosions.EXPLOSIONS.push(new Explosion(Explosion.SMALL));
    }
  }

  public static explode(x: number, y: number, strength: number): Explosion | null {
    for (let i = 0; i < Explosions.EXPLOSIONS.length; ++i) {
      let explosion: Explosion = Explosions.EXPLOSIONS[i];
      if (!explosion.isVisible()) {
        explosion.setPosition(x,y);
        explosion.setFrame(0);
        explosion.setStrength(strength);
        explosion.setVisible(true);
        if (Resources.isPlayingSound) {
          Resources.playSound(Resources.EXPLODE_SOUND);
        }
        return explosion;
      }
    }
    return null;
  }

  public static stopAllExplosions() {
    for (let i = 0; i < Explosions.EXPLOSIONS.length; i++) {
      Explosions.EXPLOSIONS[i].setVisible(false);
    }
  }

  public static setLayerManager(manager: LayerManager) {
    if (manager != null) {
      for (let i = 0; i < Explosions.EXPLOSIONS.length; i++){
        manager.append(Explosions.EXPLOSIONS[i]);
      }
    }
  }

}