import { LayerManager, Sprite } from "@ohos/core";
import Resources from "../../Resources";
import { Actor } from "../Actor";
import { BattleField } from "../BattleField";

export class Explosion extends Sprite implements Actor{
  public static SMALL: number = 0;
  public static BIG: number = 1;
  private frameSeq: number[][] = [
    [0, 1, 1, 2, 2],
    [0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5],
  ];

  constructor(strength: number) {
    let img: ImageBitmap = Resources.getImage(Resources.EXPLODE)
    super(img, img.width/6, img.height,Resources.TILE_WIDTH,Resources.TILE_WIDTH);
    super.setBorder(Resources.SHOW_BORDER);
    this.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y);
    this.setVisible(false);
    this.setStrength(strength);
  }

  tick() {
    if (!this.isVisible()) {
      return;
    }
    this.nextFrame();
    if (this.getFrame() == 0) {
      this.setVisible(false);
    }
  }

  setStrength(strength: number) {
    this.setFrameSequence(this.frameSeq[strength]);
  }

}

