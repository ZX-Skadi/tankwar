import { LayerManager, Sprite } from "@ohos/core";
import Resources from "../../Resources";
import { Actor } from "../Actor";
import { BattleField } from "../BattleField";

export class Powerup extends Sprite implements Actor{
  public static INVULNERABLE: number = 1;
  public static HOME: number = 2;
  public static HOME_DESTROYED: number = 3;
  public static TANK: number = 4;
  public static CLOCK: number = 5;
  public static SHOVEL: number = 6;
  public static BOMB: number = 7;
  public static STAR: number = 8;
  public static SHIELD: number = 9;
  public static NOTHING: number = 10;

  private battleField: BattleField|null|undefined;
  private layerManager: LayerManager|null|undefined;

  private startTime: number = 0;
  private MILLIS_PER_TICK: number = 50;
  private timeTaken: number = this.MILLIS_PER_TICK;
  private showNextFrame: boolean = false;
  private livePeriod: number = 180000;

  constructor(type: number) {
    let bonus: ImageBitmap = Resources.getImage(Resources.BONUS);
    super(bonus, bonus.width / 11, bonus.height,Resources.TILE_WIDTH,Resources.TILE_WIDTH);
    super.setBorder(Resources.SHOW_BORDER);
    this.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y);
    this.setType(type)
  }

  tick() {
    if (this.getType() == Powerup.NOTHING || !this.isVisible()) {
      return;
    }

    let tickTime: number = Date.now();
    let refreshPeriod:number = this.MILLIS_PER_TICK;

    //invulnerable powerup is controlled by the player tank.
    if (this.getType() != Powerup.INVULNERABLE && this.getType() != Powerup.HOME && this.getType() != Powerup.HOME_DESTROYED) {
      if (tickTime - this.startTime > this.livePeriod) {
        this.setFrame(Powerup.NOTHING);
        this.setVisible(false);
        return;
      }
    } else {
      refreshPeriod = this.MILLIS_PER_TICK / 10;
    }
    if (this.timeTaken >= refreshPeriod) {
      this.showNextFrame = !this.showNextFrame;
      if (this.getType() == Powerup.INVULNERABLE) {
        if (this.showNextFrame) {
          this.setFrame(0);
        } else {
          this.setFrame(1);
        }
      } else if (this.getType() == Powerup.HOME || this.getType() == Powerup.HOME_DESTROYED) {
        this.setFrame(this.getType());
      } else {
        if (this.showNextFrame) {
          this.setFrame(this.getType());
        } else {
          this.setFrame(Powerup.NOTHING);
        }
      }
      this.timeTaken = Date.now() - tickTime;
    } else {
      this.timeTaken += 1;
    }
  }

  setStartTime(startTime:number){
    this.startTime = startTime;
  }

  setLayerManager(manager: LayerManager) {
    this.layerManager = manager;
  }

  getLayerManager():LayerManager|null|undefined{
    return this.layerManager;
  }

  setBattleField(field: BattleField) {
    this.battleField = field;
  }

  getBattleField():BattleField|null|undefined{
    return this.battleField;
  }

}