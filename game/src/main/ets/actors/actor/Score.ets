import { Sprite } from "@ohos/core";
import Resources from "../../Resources";
import { Actor } from "../Actor";

export class Score extends Sprite implements Actor{
  public static SCORE_100: number = 0;
  public static SCORE_200: number = 1;
  public static SCORE_300: number = 2;
  public static SCORE_400: number = 3;
  public static SCORE_500: number = 4;

  private scoreValue: number = -1;
  private startTime: number = 0;
  private livePeriod: number = 10000;

  constructor() {
    let img: ImageBitmap = Resources.getImage(Resources.SCORE);
    super(img, img.width / 5, img.height,Resources.TILE_WIDTH,Resources.TILE_WIDTH/4);
    super.setBorder(Resources.SHOW_BORDER);
    this.setOffset(Resources.BATTLE_FIELD_X,Resources.BATTLE_FIELD_Y);
  }

  setValue(value: number) {
    this.scoreValue = value;
    this.setFrame(value);
  }

  getValue(): number {
    return this.scoreValue;
  }

  setStartTime(startTime:number){
    this.startTime = startTime;
  }

  tick() {
    if (this.isVisible()) {
      let tickTime = Date.now();
      if (this.startTime > 0) {
        if (tickTime - this.startTime > this.livePeriod) {
          this.setVisible(false);
          this.startTime = 0;
          return;
        }
      }
    }
  }

}
