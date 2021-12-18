unit actor;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, sprite, texture, resources, web, camera;

const
  FRAME_SIZE = 16;

type


  TsmPlayerState = (psNone, psWalkLeft, psWalkRight, psWalkStairsUp, psWalkStairsDown,
    psWalkRopeLeft, psWalkRopeRight, psFallLeft,
    psFallRight, psDigLeft, psDigRight, psDie, psStay);

  TOnPlayerMove = procedure(ASender: TObject; AAbsX, AAbsY: double; AX, AY: integer;
    APlayerState: TsmPlayerState; var AAllow: boolean) of object;

  TsmAvailableMove = array [0..3] of boolean;     // 0-xl, 1-xr, 2-yu, 3-yd

  { TsmActor }

  TsmActor = class(TComponent)
  private
    procedure SetPlayerState(AValue: TsmPlayerState);
  private
    FAvailableMove: TsmAvailableMove;
    FCamera: TsmCamera;
    FOnPlayerMove: TOnPlayerMove;
    FSpeed: double;
    FSprite: TsmSprite;
    FPlayerState: TsmPlayerState;
    FAbsX: double;
    FAbsY: double;
    FX: integer;
    FY: integer;
    FStopped: boolean;

    function GetLX: integer;
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
    procedure StartWalkRight;
    procedure StartWalkUp;
    procedure StartWalkDown;
    procedure DigHoleLeft;
    procedure DigHoleRight;
    procedure Die;
    procedure Stop;
    property Speed: double read FSpeed write FSpeed;
    property X: integer read FX write SetX;
    property Y: integer read FY write SetY;
    property Camera: TsmCamera read FCamera write SetCamera;
    property OnPlayerMove: TOnPlayerMove read FOnPlayerMove write FOnPlayerMove;
    property PlayerState: TsmPlayerState read FPlayerState write SetPlayerState;
  end;

implementation

{ TsmActor }

procedure TsmActor.SetPlayerState(AValue: TsmPlayerState);
begin
  //  if FPlayerState = AValue then
  //    Exit;
  FSprite.Animate := True;
  FPlayerState := AValue;
  FSprite.FrameSize := FRAME_SIZE;
  FSprite.AnimationTime := 0.4;
  FStopped := False;
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
      FSprite.AnimationTime := 0.18;
    end;
  end;
end;

procedure TsmActor.SetAbsX(AValue: double);
var
  allow: boolean;
  old: double;
begin
  if FAbsX = AValue then
    Exit;
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

function TsmActor.GetLX: integer;
begin
  Result := round((AbsX - FRAME_SIZE / 2) / FRAME_SIZE);
end;

procedure TsmActor.SetAbsY(AValue: double);
var
  allow: boolean;
begin
  if FAbsY = AValue then
    Exit;
  FAbsY := AValue;
  FY := round(FAbsY / FRAME_SIZE);
  allow := True;
  if Assigned(OnPlayerMove) then
    OnPlayerMove(Self, AbsX, AbsY, X, Y, FPlayerState, allow);
  if not allow then
  begin
    PlayerState := psStay;
  end;
end;

procedure TsmActor.SetCamera(AValue: TsmCamera);
begin
  if FCamera = AValue then Exit;
  FCamera := AValue;
  FSprite.Camera := FCamera;
end;

procedure TsmActor.SetX(AValue: integer);
begin
  FX := AValue;
  FAbsX := FX * FRAME_SIZE;
end;

procedure TsmActor.SetY(AValue: integer);
begin
  //if FY = AValue then Exit;
  FY := AValue;
  FAbsY := FY * FRAME_SIZE;
end;

constructor TsmActor.Create(AOwner: TComponent; AResources: TsmResources);
begin
  FSprite := TsmSprite.Create(AOwner, AResources.Player);
  PlayerState := psStay;
end;

destructor TsmActor.Destroy;
begin
  FreeAndNil(FSprite);
  inherited Destroy;
end;

procedure TsmActor.Draw(ACtx: TJSCanvasRenderingContext2D);
begin
  FSprite.X := trunc(AbsX);
  FSprite.Y := trunc(AbsY);
  FSprite.Update(0);
  FSprite.Draw(Actx);
end;

procedure TsmActor.Update;

  procedure CorrectY;
  begin
    if AbsY > Y * FRAME_SIZE then
      AbsY := AbsY - Speed;
    if AbsY < Y * FRAME_SIZE then
      AbsY := AbsY + Speed;
    if round(AbsY) = Y * FRAME_SIZE then
      Y := FY;
  end;

  procedure CorrectX;
  begin
    if AbsX > X * FRAME_SIZE then
      AbsX := AbsX - Speed;
    if AbsX < X * FRAME_SIZE then
      AbsX := AbsX + Speed;
    if round(AbsX) = X * FRAME_SIZE then
      X := FX;
  end;

begin
  if not FStopped then
    case PlayerState of
      psWalkLeft, psWalkRopeLeft: begin
        AbsX := AbsX - Speed;
        CorrectY;
      end;
      psWalkRight, psWalkRopeRight: begin
        AbsX := AbsX + Speed;
        CorrectY;
      end;
      psWalkStairsUp: begin
        AbsY := AbsY - Speed;
        CorrectX;
      end;
      psWalkStairsDown: begin
        AbsY := AbsY + Speed;
        CorrectX;
      end;
      psFallLeft, psFallRight: begin
        AbsY := AbsY + Speed;
        CorrectX;
      end
    end;
end;

procedure TsmActor.StopAnimation;
begin
  FSprite.Animate := False;
end;

procedure TsmActor.StartAnimation;
begin
  FSprite.Animate := True;
end;

procedure TsmActor.StartWalkLeft;
begin
  PlayerState := psWalkLeft;
end;

procedure TsmActor.StartWalkRight;
begin
  PlayerState := psWalkRight;
end;

procedure TsmActor.StartWalkUp;
begin
  PlayerState := psWalkStairsUp;
end;

procedure TsmActor.StartWalkDown;
begin
  PlayerState := psWalkStairsDown;
end;

procedure TsmActor.DigHoleLeft;
begin
  PlayerState := psDigLeft;
end;

procedure TsmActor.DigHoleRight;
begin
  PlayerState := psDigRight;
end;

procedure TsmActor.Die;
begin
  PlayerState := psDie;
end;

procedure TsmActor.Stop;
begin
  FStopped := True;
end;

end.
