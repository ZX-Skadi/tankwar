import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { MathUtil } from '../main/ets/math/MathUtil';

export default function mathUnitTest() {

  describe('mathUtilTest', () => {
    let math: MathUtil|null = null;
    let a:number = 0;
    let b:number = 0;
    let c:number = 2;
    let d:number = 6;

    beforeAll(() => {
      math = new MathUtil();
    });

    beforeEach(() => {
      a = Math.floor(Math.abs(Math.random()* 100) % 100);
      b = Math.floor(Math.abs(Math.random()* 100) % 100);
    });

    afterEach(() => {
      a = 0;
      b = 0;
    });

    afterAll(() => {
      math = null;
    });

    it('mathRandomAssert', 0, () => {
      expect(100).assertEqual(math?.add(a,b));
      expect(100).assertEqual(math?.sub(a,b));
      expect(100).assertEqual(math?.mul(a,b));
      expect(100).assertEqual(math?.div(a,b));
      expect(math?.isEven(a)).assertTrue();
    });

    it('mathNumberAssert',0,()=>{
      expect(8).assertEqual(math?.add(d,c));
      expect(4).assertEqual(math?.sub(d,c));
      expect(12).assertEqual(math?.mul(d,c));
      expect(3).assertEqual(math?.div(d,c));
      expect(math?.isEven(a)).assertTrue();
    })

  });


}