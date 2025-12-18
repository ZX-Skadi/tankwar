import { LayerManager } from "@ohos/core";
import { Score } from "./actor/Score";

export class Scores {
  public static SCORES: Score[] = [];
  public static POOL_SIZE: number = 10;

  public static create() {
    for (let i = 0; i < Scores.POOL_SIZE; i++) {
      Scores.SCORES.push(new Score());
      Scores.SCORES[i].setVisible(false);
    }
  }

  public static show(x: number, y: number, value: number): Score | null {
    for (let i = 0; i < Scores.SCORES.length; ++i) {
      let score: Score = Scores.SCORES[i];
      if (!score.isVisible()) {
        score.setStartTime(Date.now());
        score.setValue(value);
        score.setVisible(true);
        score.setPosition(x,y);
        return score;
      }
    }
    return null;
  }

  public static setLayerManager(manager: LayerManager) {
    if (manager != null) {
      for (let i = 0; i < Scores.SCORES.length; i++) {
        manager.append(Scores.SCORES[i]);
      }
    }
  }

}


