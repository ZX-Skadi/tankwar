import { beforeEach, describe, expect, it } from "@ohos/hypium";
import { DataService } from "../mock/DataService";

export default function dataUnitTest() {

  describe('dataMock', () => {
    let data: string[] = [];
    let fetchData: () => Promise<string[]>;

    beforeEach(async () => {
      // data = DataService.fetchListData(1, 2);
      fetchData=() => DataService.fetchListData(1, 2)
      let initData = await fetchData?.();
      if (initData) data = initData;
    });

    // 测试 1：正常场景 - mock 返回 2 条数据
    it('LoadData',0, async () => {
      expect(data.length).assertEqual(2);
      expect(data).assertDeepEquals(['Mock数据-Page1-Item1', 'Mock数据-Page1-Item2']);
    });
  });

}