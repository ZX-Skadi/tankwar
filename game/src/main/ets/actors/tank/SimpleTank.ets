import { Score } from "../actor/Score";
import { BattleField } from "../BattleField";
import { Tanks } from "../Tanks";
import { EnemyTank } from "./EnemyTank";

export class SimpleTank extends EnemyTank {
  constructor(hasPrize: boolean) {
    super(hasPrize);
    this.setType(Tanks.TYPE_SIMPLE);
    this.setScore(Score.SCORE_100)
  }

  think() {
    let changeDirection = Math.floor(Math.abs(Math.random() * 101) % 100);
    if (changeDirection > 90) {
      this.setDirection( Math.floor(Math.abs(Math.random() * 5) % 4));
    } else if (changeDirection > 80) {
      this.setDirection( BattleField.SOUTH);
    }
    let shooting = Math.floor(Math.abs(Math.random() * 101) % 100);
    this.setShooting(false);
    if (shooting >= 50) {
      this.setShooting(true);
    }
    super.think();
  }

}