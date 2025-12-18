import { media } from "@kit.MediaKit";
import { audio } from "@kit.AudioKit";
import { BusinessError } from "@kit.BasicServicesKit";

export default class Resources{
  public static TILE_WIDTH:number=48;
  public static BATTLE_FIELD_X:number = 0;
  public static BATTLE_FIELD_Y:number = 0;
  public static SHOW_GRID:boolean = false;
  public static SHOW_BORDER:boolean = false;

  public static BONUS: number = 0;
  public static EXPLODE: number = 1;
  public static BULLET: number = 2;
  public static PLAYER: number = 3;
  public static ENEMY: number = 4;
  public static SPLASH: number = 10;
  public static SCORE_SCREEN: number = 11;
  public static PLAYER_ICON: number = 12;
  public static FLAG: number = 13;
  public static ENEMY_ICON: number = 14;
  public static NUMBER_WHITE: number = 15;
  public static NUMBER_RED: number = 16;
  public static GAME_OVER_BIG: number = 17;
  public static GAME_OVER_SMALL: number = 18;
  public static SCORE: number = 19;
  public static PAUSE: number = 20;
  public static NUMBER_BLACK: number = 21;
  public static STAGE: number = 22;
  public static TURN_SOUND: number = 23;
  public static GAME_HELP: number = 27;
  public static GUIDEBEE_LOGO: number = 28;
  public static IP: number = 29;

  public static isPlayingSound:boolean=false;
  public static SCORE_SOUND:number=1;
  public static OPEN_SOUND:number=2;
  public static GAMEOVER_SOUND:number=0;
  public static EXPLODE_SOUND:number=4;
  public static SHOOT_SOUND:number=3;

  public static loaded:boolean = false;
  public static stageFromTop2Bottom: boolean = false;
  public static highScore:number = 20000;

  public static gameLevel:number=1;
  private static images: ImageBitmap [] = [
    new ImageBitmap('raw/img00.jpeg'),
    new ImageBitmap('raw/img01.jpeg'),
    new ImageBitmap('raw/img02.jpeg'),
    new ImageBitmap('raw/img03.jpeg'),
    new ImageBitmap('raw/img04.jpeg'),
    new ImageBitmap('raw/img05.jpeg'),
    new ImageBitmap('raw/img06.jpeg'),
    new ImageBitmap('raw/img07.jpeg'),
    new ImageBitmap('raw/img08.jpeg'),
    new ImageBitmap('raw/img09.jpeg'),
    new ImageBitmap('raw/img10.jpeg'),
    new ImageBitmap('raw/img11.jpeg'),
    new ImageBitmap('raw/img12.png'),
    new ImageBitmap('raw/img13.png'),
    new ImageBitmap('raw/img14.png'),
    new ImageBitmap('raw/img15.jpeg'),
    new ImageBitmap('raw/img16.jpeg'),
    new ImageBitmap('raw/img17.jpeg'),
    new ImageBitmap('raw/img18.png'),
    new ImageBitmap('raw/img19.jpeg'),
    new ImageBitmap('raw/img20.jpeg'),
    new ImageBitmap('raw/img21.png'),
    new ImageBitmap('raw/img22.jpeg'),
    new ImageBitmap('raw/img23.jpeg'),
    new ImageBitmap('raw/img24.jpeg'),
    new ImageBitmap('raw/img25.jpeg'),
    new ImageBitmap('raw/img26.jpeg'),
    new ImageBitmap('raw/img27.jpeg'),
    new ImageBitmap('raw/guidebee.png'),
    new ImageBitmap('raw/ip.png'),
  ]
  private static tileImage:ImageBitmap
  private static settings: RenderingContextSettings = new RenderingContextSettings(true)

  private static soundPool: media.SoundPool;
  private static audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
    rendererFlags: 1
  }
  private static playParameters: media.PlayParameters = {
    loop:0,
    rate: audio.AudioRendererRate.RENDER_RATE_NORMAL,
    leftVolume:1,
    rightVolume:1,
    priority:0
  }
  private static SOUND_IDS:number[] = [-1,-1,-1,-1,-1];

  private static createSounds() {
    media.createSoundPool(5,Resources.audioRendererInfo,(error: BusinessError, soundPool_: media.SoundPool) => {
      if(error){
        console.error("Failed to create sound pool")
        return;
      }else{
        Resources.soundPool = soundPool_;
        for(let i=1;i<=5;i++){
          Resources.loadSound(i)
        }
      }
    })
  }

  private static loadSound(no:number){
    getContext().resourceManager.getRawFd('snd'+no+'.mp3', async (error,fd)=>{
      await Resources.soundPool.load(fd.fd,fd.offset,fd.length).then((soundId:number)=>{
        Resources.SOUND_IDS[no-1]=soundId;
      })
    })
  }

  public static playSound(type:number){
    Resources.soundPool.play(Resources.SOUND_IDS[type], Resources.playParameters).then((streamId: number) => {
      console.info('Succeeded in playing soundpool');
    },(err: BusinessError) => {
      console.error('Failed to play soundpool and catch error is ' + err.message);
    });
  }


  public static getTileImage():ImageBitmap{
    return Resources.tileImage;
  }

  public static loadResources(){
    let t:ImageBitmap = Resources.images[5]
    let offCanvas:OffscreenCanvas = new OffscreenCanvas(t.width * 6, t.height)
    let g = offCanvas.getContext("2d", Resources.settings)
    let imgWidth = 0;
    for(let i=5;i<10;i++){
      t = Resources.images[i];
      g.drawImage(Resources.images[i],imgWidth,0);
      imgWidth+=t.width;
    }
    Resources.tileImage = g.transferToImageBitmap()
    for(let i=5;i<10;i++){
      Resources.images[i]=null!;
    }
    Resources.createSounds();
    Resources.loaded = true;
  }

  public static getImage(index:number):ImageBitmap{
    return Resources.images[index];
  }

}
