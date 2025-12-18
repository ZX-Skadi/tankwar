import Resources from "../../Resources";
import { Score } from "../actor/Score";
import { Tanks } from "../Tanks";
import { SimpleTank } from "./SimpleTank";

export class FastTank extends SimpleTank{
  constructor(hasPrize: boolean) {
    super(hasPrize);
    this.setSpeed(Resources.TILE_WIDTH / 2)
    this.setType(Tanks.TYPE_FAST)
    this.setScore(Score.SCORE_200)
  }
}
