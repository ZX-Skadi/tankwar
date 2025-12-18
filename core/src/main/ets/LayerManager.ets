import { Layer } from "./Layer";

export class LayerManager{
  private layers:Layer[] = [];

  constructor() {
    this.layers = [];
  }

  append(layer:Layer) {
    this.layers.push(layer);
  }

  getLayerAt(i:number):Layer {
    return this.layers[i];
  }

  getSize():number {
    return this.layers.length;
  }

  insert(layer:Layer, i:number):void {
    this.layers.fill(layer,i);
  }

  remove(layer:Layer):void {
    let idx = this.layers.indexOf(layer,0)
    this.layers.splice(idx,1);
  }

  paint(g: CanvasRenderingContext2D) {
    for (let i = this.getSize(); --i >= 0;) {
      let comp:Layer = this.getLayerAt(i);
      if (comp.isVisible()) {
        comp.paint(g);
      }
    }
  }

}