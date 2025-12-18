import Resources from "../../Resources";
import { Score } from "../actor/Score";
import { Tanks } from "../Tanks";
import { SimpleTank } from "./SimpleTank";

export class HeavyTank extends SimpleTank{
  constructor(hasPrize: boolean) {
    super(hasPrize);
    this.setSpeed(Resources.TILE_WIDTH / 6)
    this.setType(Tanks.TYPE_HEAVY)
    this.setScore(Score.SCORE_400)
  }
}

