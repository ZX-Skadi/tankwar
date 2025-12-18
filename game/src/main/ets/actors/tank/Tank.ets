import { LayerManager, Sprite } from "@ohos/core";
import Resources from "../../Resources";
import { Actor } from "../Actor";
import { Bullet } from "../actor/Bullet";
import { Explosion } from "../actor/Explosion";
import { BattleField } from "../BattleField";
import { Explosions } from "../Explosions";
import { Tanks } from "../Tanks";

export abstract class Tank extends Sprite implements Actor{
  private battleField: BattleField|null|undefined;
  private layerManager: LayerManager|null|undefined;

  private driveStartTime: number = 0;
  private minimumDrivePeriod: number = 40;
  private shooting: boolean = false;
  private newBornTimer: number = 0;

  constructor(image: ImageBitmap, frameWidth: number, frameHeight: number) {
    super(image, frameWidth, frameHeight, Resources.TILE_WIDTH, Resources.TILE_WIDTH);
    super.setBorder(Resources.SHOW_BORDER);
    this.setSpeed(Resources.TILE_WIDTH/4);
    this.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y)
  }

  setLayerManager(manager: LayerManager) {
    this.layerManager = manager;
  }

  setBattleField(field: BattleField) {
    this.battleField = field;
  }

  getLayerManager():LayerManager|null|undefined{
    return this.layerManager;
  }

  getBattleField():BattleField|null|undefined{
    return this.battleField;
  }

  abstract initTank();

  tick(): void {
    if (this.isVisible()) {
      this.think();
      this.drive();
      this.shoot();
    }
  }

  abstract think();

  abstract  shoot() : Bullet|null;

  tryMove(dx: number, dy: number) {
    this.move(dx, dy);
    if (Tanks.overlapsTank(this)){
      this.move(-dx, -dy);
    }
  }

  drive() {
    try {
      let tickTime = Date.now();
      let canDrive: boolean = (tickTime - this.driveStartTime) > this.minimumDrivePeriod;
      let onSnow: boolean = this.battleField!.isOnSnow(this.getX(), this.getY());
      let extraPace: number = 0;

      if (onSnow) {
        extraPace = this.getSpeed();
      }
      if (canDrive) {
        switch (this.getDirection()) {
          case BattleField.NORTH:
            if ((this.getY() > 0) && !this.battleField!.containsImpassableArea(
              this.getX(), this.getY() - this.getSpeed(), this.getWidth(), this.getSpeed()
            )) {
              this.tryMove(0, -this.getSpeed());
            }
            break;
          case BattleField.EAST:
            if ((this.getX() < this.battleField!.getWidth() - Resources.TILE_WIDTH) &&
              !this.battleField!.containsImpassableArea(
                this.getX() + this.getWidth(), this.getY(), this.getSpeed(), this.getHeight()
              )
            ) {
              this.tryMove(this.getSpeed(), 0);
            }
            break;
          case BattleField.SOUTH:
            if ((this.getY() < this.battleField!.getHeight() - Resources.TILE_WIDTH) &&
              !this.battleField!.containsImpassableArea(
                this.getX(), this.getY() + this.getHeight(), this.getWidth(), this.getSpeed()
              )
            ) {
              this.tryMove(0, this.getSpeed());
            }
            break;
          case BattleField.WEST:
            if ((this.getX() > 0) && !this.battleField!.containsImpassableArea(
              this.getX() - this.getSpeed(), this.getY(), this.getSpeed(), this.getHeight()
            )) {
              this.tryMove(-this.getSpeed(), 0);
            }
            break;
        }
        this.driveStartTime = tickTime;
      }
    } catch (e) {
      console.error(":::::::::",e)
    }
  }

  changeDirection(direction: number) {
    this.setDirection(direction);
  }

  isShooting():boolean{
    return this.shooting;
  }

  setShooting(shooting:boolean){
    this.shooting = shooting;
  }

  setNewBornTimer(newBornTimer:number){
    this.newBornTimer = newBornTimer;
  }

  getNewBornTimer():number{
    return this.newBornTimer;
  }

  explode() {
    let x = this.getX();
    let y = this.getY();
    Explosions.explode(x, y, Explosion.BIG);
    this.setVisible(false)
  }

}

