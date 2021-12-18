unit player;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, sprite, texture, resources, web, camera;

const
  FRAME_SIZE = 16;

type


  TsmPlayerState = (psNone, psWalkLeft, psWalkRight, psWalkStairsUp, psWalkStairsDown, psWalkRopeLeft, psWalkRopeRight, psFallLeft,
    psFallRight, psDigLeft, psDigRight, psDie, psStay);

  TOnPlayerMove = procedure(ASender: TObject; AAbsX, AAbsY: double; AX, AY: integer; APlayerState: TsmPlayerState;
    var AAllow: boolean) of object;

  { TsmPlayer }

  TsmPlayer = class(TComponent)
  private
    procedure SetPlayerState(AValue: TsmPlayerState);
  private
    FCamera: TsmCamera;
    FOnPlayerMove: TOnPlayerMove;
    FSprite: TsmSprite;
    FPlayerState: TsmPlayerState;
    FAbsX: double;
    FAbsY: double;
    FX: integer;
    FY: integer;
    procedure SetAbsX(AValue: double);
    procedure SetAbsY(AValue: double);
    procedure SetCamera(AValue: TsmCamera);
    procedure SetX(AValue: integer);
    procedure SetY(AValue: integer);
  public
    constructor Create(AOwner: TComponent; AResources: TsmResources); virtual;
    destructor Destroy; override;
    procedure Draw(ACtx: TJSCanvasRenderingContext2D);
    procedure Update;
    property AbsX: double read FAbsX write SetAbsX;
    property AbsY: double read FAbsY write SetAbsY;
    procedure StopAnimation;
    procedure StartAnimation;
    procedure StartWalkLeft;
    procedure StopWalkLeft;
    procedure StartWalkRight;
    procedure StopWalkRight;
    procedure StartWalkUp;
    procedure StopWalkUp;
    procedure StartWalkDown;
    procedure StopWalkDown;
    procedure DigHoleLeft;
    procedure DigHoleRight;
    property X: integer read FX write SetX;
    property Y: integer read FY write SetY;
    property Camera: TsmCamera read FCamera write SetCamera;
    property OnPlayerMove: TOnPlayerMove read FOnPlayerMove write FOnPlayerMove;
    property PlayerState: TsmPlayerState read FPlayerState write SetPlayerState;
  end;

implementation

{ TsmPlayer }

procedure TsmPlayer.SetPlayerState(AValue: TsmPlayerState);
begin
  if FPlayerState = AValue then
    Exit;
  FSprite.Animate := True;
  FPlayerState := AValue;
  FSprite.FrameSize := FRAME_SIZE;
  FSprite.AnimationTime := 0.4;

  case FPlayerState of
    psStay: begin
      FSprite.FrameCount := 2;
      FSprite.StartFrame := 16;
      FSprite.AnimationTime := 0.02;
    end;
    psWalkLeft: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 0;
    end;
    psWalkRight: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 4;
    end;
    psWalkStairsUp, psWalkStairsDown: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 48;
    end;
    psWalkRopeLeft: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 24;
    end;
    psWalkRopeRight: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 28;
    end;
    psFallLeft: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 8;
    end;
    psFallRight: begin
      FSprite.FrameCount := 4;
      FSprite.StartFrame := 12;
    end;
    psDigLeft: begin
      FSprite.FrameCount := 2;
      FSprite.StartFrame := 18;
      FSprite.AnimationTime := 0.2;
    end;
    psDigRight: begin
      FSprite.FrameCount := 2;
      FSprite.StartFrame := 20;
      FSprite.AnimationTime := 0.2;
    end;
    psDie: begin
      FSprite.FrameCount := 8;
      FSprite.StartFrame := 32;
      FSprite.AnimationTime := 0.2;
    end;
  end;
end;

procedure TsmPlayer.SetAbsX(AValue: double);
var
  allow: boolean;
  old: double;
begin
  if FAbsX = AValue then Exit;
  old := FAbsX;
  FAbsX := AValue;
  FX := round(FAbsX / FRAME_SIZE);
  allow := True;

  if Assigned(OnPlayerMove) then
    OnPlayerMove(Self, AbsX, AbsY, X, Y, FPlayerState, allow);
  if not allow then
  begin
    FAbsX := old;
    PlayerState := psStay;
  end;
end;

procedure TsmPlayer.SetAbsY(AValue: double);
var
  allow: boolean;
  old: double;
begin
  if FAbsY = AValue then Exit;
  old := FAbsY;
  FAbsY := AValue;
  FY := round(FAbsY / FRAME_SIZE);
  allow := True;
  if Assigned(OnPlayerMove) then
    OnPlayerMove(Self, AbsX, AbsY, X, Y, FPlayerState, allow);
  if not allow then
  begin
    //FAbsY := old;
    PlayerState := psStay;
  end;
end;

procedure TsmPlayer.SetCamera(AValue: TsmCamera);
begin
  if FCamera = AValue then Exit;
  FCamera := AValue;
  FSprite.Camera := FCamera;
end;

procedure TsmPlayer.SetX(AValue: integer);
begin
  FX := AValue;
  FAbsX := FX * FRAME_SIZE;
end;

procedure TsmPlayer.SetY(AValue: integer);
begin
  //if FY = AValue then Exit;
  FY := AValue;
  FAbsY := FY * FRAME_SIZE;
end;

constructor TsmPlayer.Create(AOwner: TComponent; AResources: TsmResources);
begin
  FSprite := TsmSprite.Create(AOwner, AResources.Player);
  PlayerState := psStay;
end;

destructor TsmPlayer.Destroy;
begin
  FreeAndNil(FSprite);
  inherited Destroy;
end;

procedure TsmPlayer.Draw(ACtx: TJSCanvasRenderingContext2D);
begin
  FSprite.X := trunc(AbsX);
  FSprite.Y := trunc(AbsY);
  ACtx.strokeStyle := '#FFFFFF66';
  ACtx.strokeRect(FX * FRAME_SIZE + Camera.X, FY * FRAME_SIZE + Camera.Y, FRAME_SIZE, FRAME_SIZE);
  FSprite.Draw(Actx);
end;

procedure TsmPlayer.Update;
begin

end;

procedure TsmPlayer.StopAnimation;
begin
  //writeln('Stop');
  FSprite.Animate := False;
end;

procedure TsmPlayer.StartAnimation;
begin
  FSprite.Animate := True;
end;

procedure TsmPlayer.StartWalkLeft;
begin
  PlayerState := psWalkLeft;
  Y := FY;
end;

procedure TsmPlayer.StopWalkLeft;
begin
  PlayerState := psStay;
end;

procedure TsmPlayer.StartWalkRight;
begin
  PlayerState := psWalkRight;
  Y := FY;
end;

procedure TsmPlayer.StopWalkRight;
begin
  PlayerState := psStay;
end;

procedure TsmPlayer.StartWalkUp;
begin
  PlayerState := psWalkStairsUp;
  X := FX;
end;

procedure TsmPlayer.StartWalkDown;
begin
  PlayerState := psWalkStairsDown;
  X := FX;
end;

procedure TsmPlayer.StopWalkUp;
begin
  PlayerState := psStay;
  X := FX;
end;

procedure TsmPlayer.StopWalkDown;
begin
  PlayerState := psStay;
end;

procedure TsmPlayer.DigHoleLeft;
begin
  PlayerState := psDigLeft;
  X := FX;
end;

procedure TsmPlayer.DigHoleRight;
begin
  PlayerState := psDigRight;
  X := FX;
end;

end.
