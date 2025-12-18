// main/ets/services/DataService.ets（真实数据服务）
export class DataService {
  /** 真实逻辑：调用后端接口获取列表数据（依赖网络） */
  static async fetchListData(page: number, size: number): Promise<string[]> {
    // 真实场景：axios.get('/api/list') 等网络请求
    return new Promise((resolve) => {
      setTimeout(() => {
        // 真实接口返回的模拟数据（实际由后端返回）
        // const data = Array.from({ length: size }, (_, i) => `真实数据-Page${page}-Item${i+1}`);
        let data:string [] =[];
        for(let i=0;i<size;i++){
          data.push('Mock数据-Page'+page+'-Item'+(i+1));
        }
        resolve(data);
      }, 500); // 真实网络延迟（500ms）
    });
  }
}