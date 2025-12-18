
export class MathUtil{
  add(a:number,b:number):number{
    return a + b;
  }

  sub(a:number,b:number):number{
    return a - b;
  }

  mul(a:number,b:number):number{
    return a * b;
  }

  div(a:number,b:number):number{
    return a / b;
  }

  isEven(a:number):boolean{
    return a % 2 === 0;
  }

}