unit sprite;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, component, web, texture, camera, Generics.Collections;

type

  { TsmSprite }

  TsmSprite = class(TComponent)
  private
    FAnimate: boolean;
    FAnimationTime: double;
    FCamera: TsmCamera;
    FFameCount: integer;
    FFrameCount: integer;
    FFrameSize: integer;
    FOnEndFrame: TNotifyEvent;
    FOnStartFrame: TNotifyEvent;
    FStartFrame: integer;
    FTexture: TsmTexture;
    FFrameXStart, FFrameYStart: integer;
    FX: integer;
    FY: integer;
    FNextFrame: double;
    FTotalRows: integer;
    procedure SetAnimate(AValue: boolean);
    procedure SetFrameCount(AValue: integer);
    procedure SetFrameSize(AValue: integer);
    procedure SetStartFrame(AValue: integer);
    procedure RecalcFrame;
    function GetFrameRow: integer;
    function GetFrameCol: integer;
    procedure NextFrame;
  public
    constructor Create(AOwner: TComponent; ATexture: TsmTexture); virtual;
    procedure Draw(ACtx: TJSCanvasRenderingContext2D);
    procedure Update(ADelta: double);
    procedure Restart;
    property X: integer read FX write FX;
    property Y: integer read FY write FY;
    property Animate: boolean read FAnimate write SetAnimate;
    property FrameCount: integer read FFameCount write SetFrameCount;
    property StartFrame: integer read FStartFrame write SetStartFrame;
    property FrameSize: integer read FFrameSize write SetFrameSize;
    property AnimationTime: double read FAnimationTime write FAnimationTime;
    property Camera: TsmCamera read FCamera write FCamera;
    property OnStartFrame: TNotifyEvent read FOnStartFrame write FOnStartFrame;
    property OnEndFrame: TNotifyEvent read FOnEndFrame write FOnEndFrame;
  end;

  TsmSpriteList = specialize TList<TsmSprite>;


implementation

{ TsmSprite }

procedure TsmSprite.SetFrameCount(AValue: integer);
begin
  if FFameCount = AValue then Exit;
  FFameCount := AValue;
  RecalcFrame;
end;

procedure TsmSprite.SetFrameSize(AValue: integer);
begin
  if FFrameSize = AValue then Exit;
  FFrameSize := AValue;
  RecalcFrame;
end;

procedure TsmSprite.SetAnimate(AValue: boolean);
begin
  if FAnimate = AValue then Exit;
  FAnimate := AValue;
  RecalcFrame;
end;

procedure TsmSprite.SetStartFrame(AValue: integer);
begin
  if FStartFrame = AValue then Exit;
  FStartFrame := AValue;
  FNextFrame := FStartFrame;
  RecalcFrame;
end;

procedure TsmSprite.RecalcFrame;
begin
  FTotalRows := trunc(FTexture.Width / FrameSize);
end;

function TsmSprite.GetFrameRow: integer;
begin
  Result := trunc(trunc(FNextFrame) / FTotalRows);
end;

function TsmSprite.GetFrameCol: integer;
begin
  Result := trunc(FNextFrame) mod FTotalRows;
end;

procedure TsmSprite.NextFrame;
begin
  if not Animate then exit;

  if Assigned(OnStartFrame) then
    if (round(FNextFrame) = FStartFrame) then
      OnStartFrame(Self);

  FNextFrame := FNextFrame + AnimationTime;


  if Assigned(OnEndFrame) then
    if (FNextFrame + AnimationTime > FStartFrame + FFameCount) then
      OnEndFrame(Self);

  if FNextFrame > FStartFrame + FFameCount then
    FNextFrame := FStartFrame;


  //  writeln(FNextFrame);
end;

constructor TsmSprite.Create(AOwner: TComponent; ATexture: TsmTexture);
begin
  inherited Create(AOwner);
  FTexture := ATexture;
  FX := 0;
  FY := 0;
  Animate := True;
end;

procedure TsmSprite.Draw(ACtx: TJSCanvasRenderingContext2D);
begin
  ACtx.drawImage(TJSHTMLImageElement(FTexture.HTMLElement), GetFrameCol * FFrameSize, GetFrameRow * FFrameSize,
    FFrameSize, FFrameSize, X + Camera.X, Y + Camera.Y, FFrameSize, FFrameSize);
end;

procedure TsmSprite.Update(ADelta: double);
begin
  NextFrame;
end;

procedure TsmSprite.Restart;
begin
  FNextFrame := FStartFrame;
  Animate := True;
end;

end.
