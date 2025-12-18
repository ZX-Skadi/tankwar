import dataUnitTest from './DataUnit.test';
import mathUnitTest from './MathUnit.test';
import localUnitTest from './MathUnit.test';

export default function testsuite() {
  mathUnitTest();
  dataUnitTest();
}