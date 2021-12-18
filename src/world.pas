unit world;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, drawpanel, component, resources, actor, sprite,
  timer, web, js, camera, enemymanager, common, Generics.Collections;

type



  { TsmWorld }

  TsmWorld = class(TComponent)
  private
    FCamera: TsmCamera;
    FWorldWidth: integer;
    FWorldHeight: integer;
    FWorldArray: TsmWorldObj;
    FScreenScroll: integer;
    FDrawPanel: TsmDrawPanel;
    FMainElement: TsmComponent;
    FResources: TsmResources;
    FPlayer: TsmActor;
    FWorldSprite: TsmSprite;
    FDigHoleSprite: TsmSprite;
    FDigRestoreSpriteList: TsmSpriteList;
    FUpdateTimer: TsmTimer;
    FPressedKey: set of TsmKey;
    FPlayerFall: boolean;
    FPlayerDie: boolean;
    FDig: boolean;
    FGoldCount: integer;
    FHoleList: TsmHoleList;
    FEnemyManager: TsmEnemyManager;
    procedure DrawTimer(Sender: TObject);
    procedure EndDigHandle(Sender: TObject);
    procedure EndRestoreHoleHandle(Sender: TObject);
    function KeyDownHandler(aEvent: TJSKeyBoardEvent): boolean;
    function KeyUpHandler(aEvent: TJSKeyBoardEvent): boolean;
    procedure LoadEndHandler(Sender: TObject);
    procedure NotifyLoadEnd(Sender: TObject);
    procedure DrawMap;
    procedure MovePlayer;
    function CanMove(AAbsX, AAbsY: double): boolean;
    function CanFall(AAbsX, AAbsY: double): boolean;
    function CanDig(AX, AY: integer): boolean;
    procedure StartGame;
    procedure CheckFall;
    procedure CheckGold;
    procedure CheckHole;
    procedure StartRestoreHole(AX, AY: integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
  end;

implementation

{ TsmWorld }

procedure TsmWorld.NotifyLoadEnd(Sender: TObject);
var
  i, j, k: integer;
begin
  FPlayer := TsmActor.Create(FDrawPanel, FResources);
  FPlayer.Camera := FCamera;
  FPlayer.X := 10;
  FPlayer.Y := 12;
  FPlayer.Speed := PLAYER_WALK_SPEED;
  FResources.OnLoadEnd := @LoadEndHandler;
  FUpdateTimer.Interval := Trunc(1000 / FPS);
  FUpdateTimer.OnTimer := @DrawTimer;
  FUpdateTimer.Active := True;

  FWorldSprite := TsmSprite.Create(self, FResources.Tile);
  FWorldSprite.Camera := FCamera;
  FWorldSprite.Animate := True;
  FWorldSprite.FrameSize := 16;
  FWorldSprite.FrameCount := 1;
  FWorldSprite.StartFrame := 2;

  k := 0;
  FGoldCount := 0;
  for i := 0 to FWorldHeight - 1 do       // row
    for j := 0 to FWorldWidth - 1 do      // col
    begin
      FWorldArray.Item[j, i] := byte(TJSArray(tjsobject(TJSArray(FResources.Map.Map.Properties['layers'])
        [0]).Properties['data'])[k]);
      // Write(FWorldArray[j, i]);
      if FWorldArray.Item[j, i] = 7 then Inc(FGoldCount);
      k := k + 1;
    end;
  FDigHoleSprite := TsmSprite.Create(self, FResources.Dig);
  FDigHoleSprite.Camera := FCamera;
  FDigHoleSprite.FrameSize := 16;
  FDigHoleSprite.FrameCount := 5;
  FDigHoleSprite.StartFrame := 0;
  FDigHoleSprite.AnimationTime := 0.2;
  FDigHoleSprite.Animate := False;
  FDigHoleSprite.OnEndFrame := @EndDigHandle;

  FDigRestoreSpriteList := TsmSpriteList.Create();
  FEnemyManager := TsmEnemyManager.Create(FWorldArray, FPlayer, FResources);
  DrawMap;
end;

procedure TsmWorld.DrawMap;
var
  i, j: integer;
begin
  for i := 0 to FWorldHeight - 1 do
    for j := 0 to FWorldWidth - 1 do
    begin
      if (FGoldCount = 0) and (FWorldArray.Item[j, i] = 6) then
        FWorldArray.Item[j, i] := 3;
      if FWorldArray.Item[j, i] <> 6 then
        FWorldSprite.StartFrame := FWorldArray.Item[j, i] - 1
      else
        FWorldSprite.StartFrame := -1;


      FWorldSprite.x := j * FRAME_SIZE;
      FWorldSprite.y := i * FRAME_SIZE;
      FWorldSprite.Draw(FDrawPanel.Context);
    end;
end;

procedure TsmWorld.MovePlayer;
var
  ps: TsmPlayerState;
  ay: integer;
  hole: TsmHole;
begin
  ps := psStay;

  if (not FDig) and (not FPlayerFall) then
  begin

    if (pkDigLeft in FPressedKey) and (CanDig(FPlayer.X - 1, FPlayer.Y + 1)) then
    begin
      FPlayer.X := FPlayer.X;
      FDig := True;
      hole := TsmHole.Create;
      hole.X := FPlayer.X - 1;
      hole.Y := FPlayer.Y + 1;
      hole.Time := HOLE_LIFE_TIME;
      FWorldArray.Item[hole.X, hole.Y] := 0;
      FHoleList.Add(hole);
      FDigHoleSprite.Restart;
      FDigHoleSprite.X := hole.X * FRAME_SIZE;
      FDigHoleSprite.Y := hole.Y * FRAME_SIZE;
      FDigHoleSprite.Animate := True;
      FPressedKey := FPressedKey - [pkDigLeft];
      FPlayer.DigHoleLeft;
      exit;
    end;

    if (pkDigRight in FPressedKey) and (CanDig(FPlayer.X + 1, FPlayer.Y + 1)) then
    begin
      FPlayer.X := FPlayer.X;
      FDig := True;
      hole := TsmHole.Create;
      hole.X := FPlayer.X + 1;
      hole.Y := FPlayer.Y + 1;
      hole.Time := HOLE_LIFE_TIME;
      FWorldArray.Item[hole.X, hole.Y] := 0;
      FHoleList.Add(hole);
      FDigHoleSprite.X := hole.X * FRAME_SIZE;
      FDigHoleSprite.Y := hole.Y * FRAME_SIZE;
      FDigHoleSprite.Animate := True;
      FDigHoleSprite.Restart;
      FPressedKey := FPressedKey - [pkDigRight];
      FPlayer.DigHoleRight;
      exit;
    end;
  end;
  //  else
  //    exit;

  if FPlayerDie then
  begin
    FPlayer.PlayerState := psDie;
    exit;
  end;

  if not FPlayerFall then
  begin
    if (pkLeft in FPressedKey) and (not (pkRight in FPressedKey)) then
      if CanMove(FPlayer.AbsX - FPlayer.Speed - 8, FPlayer.AbsY) then
        ps := psWalkLeft
      else
        FPlayer.X := FPlayer.X;
    if (pkRight in FPressedKey) and (not (pkLeft in FPressedKey)) then
      if CanMove(FPlayer.AbsX + FPlayer.Speed + 8, FPlayer.AbsY) then
        ps := psWalkRight
      else
        FPlayer.X := FPlayer.X;
    if (pkUp in FPressedKey) and (not (pkDown in FPressedKey)) then
      if CanMove(FPlayer.AbsX, FPlayer.AbsY - FPlayer.Speed - 8) then
        ps := psWalkStairsUp
      else
        FPlayer.Y := FPlayer.Y;

    if (pkDown in FPressedKey) and (not (pkUp in FPressedKey)) then
      if CanMove(FPlayer.AbsX, FPlayer.AbsY + FPlayer.Speed + 8) then
        ps := psWalkStairsDown
      else
      begin
        if CanFall(FPlayer.AbsX, FPlayer.AbsY + PLAYER_WALK_SPEED + 8) then
        begin
          FPlayerFall := True;
        end
        else
          FPlayer.Y := FPlayer.Y;
      end;
    CheckFall;
  end
  else
  begin
    ps := FPlayer.PlayerState;
    if CanFall(FPlayer.AbsX, FPlayer.AbsY + PLAYER_WALK_SPEED + 8) then
    begin
      if (FPlayer.PlayerState = psWalkLeft) or (FPlayer.PlayerState = psWalkRopeLeft) then
        ps := psFallLeft;
      if (FPlayer.PlayerState = psWalkRight) or (FPlayer.PlayerState = psWalkRopeRight) then
        ps := psFallRight;
      if ps = psStay then ps := psFallLeft;

      if abs(FPlayer.Y * FRAME_SIZE - FPlayer.AbsY - PLAYER_WALK_SPEED) <= PLAYER_WALK_SPEED / 2 then
        if FWorldArray.Item[FPlayer.x, FPlayer.y] = 4 then
        begin
          FPlayerFall := False;
          FPlayer.Y := FPlayer.Y;
          if ps = psFallRight then
            ps := psWalkRopeRight;
          if ps = psFallLeft then
            ps := psWalkRopeLeft;
        end;
    end
    else
    begin
      FPlayerFall := False;
      FPlayer.Y := FPlayer.Y;
      if FWorldArray.Item[FPlayer.X, FPlayer.y] = 4 then
        if FPlayer.PlayerState = psFallLeft then
          ps := psWalkRopeLeft
        else
          ps := psWalkRopeRight
      else
        ps := psStay;

    end;
  end;
  if (ps = psWalkLeft) and (FWorldArray.Item[FPlayer.X, FPlayer.Y] = 4) then
    ps := psWalkRopeLeft;
  if (ps = psWalkRight) and (FWorldArray.Item[FPlayer.X, FPlayer.Y] = 4) then
    ps := psWalkRopeRight;

  if ((FWorldArray.Item[FPlayer.X, FPlayer.Y] = 4) or (FWorldArray.Item[FPlayer.X, FPlayer.Y] = 3)) and
    (ps = psStay) then
  begin
    FPlayer.Stop;
    FPlayer.StopAnimation;
  end
  else
    FPlayer.PlayerState := ps;

end;

function TsmWorld.CanMove(AAbsX, AAbsY: double): boolean;
var
  ax, ay: integer;
begin
  Result := False;
  ax := Round(AAbsX / FRAME_SIZE);
  ay := Round(AAbsY / FRAME_SIZE);

  if (FWorldArray.Item[ax, ay] <> 2) and (FWorldArray.Item[ax, ay] <> 1) then
    Result := True;

  if FPlayer.AbsY <> AAbsY then
  begin
    if (FWorldArray.Item[ax, ay] = 3) or (((FWorldArray.Item[ax, ay] = 0) or (FWorldArray.Item[ax, ay] = 4)) and
      (FWorldArray.Item[ax, ay + 1] = 3)) then
      Result := True
    else
      Result := False;
  end;
end;

function TsmWorld.CanFall(AAbsX, AAbsY: double): boolean;
var
  ax, ay: integer;
begin
  Result := False;
  ax := Round(AAbsX / FRAME_SIZE);
  ay := Round(AAbsY / FRAME_SIZE);
  if (FWorldArray.Item[ax, ay] <> 2) and (FWorldArray.Item[ax, ay] <> 1) and (FWorldArray.Item[ax, ay] <> 3) then
    Result := True;
end;

function TsmWorld.CanDig(AX, AY: integer): boolean;
begin
  Result := False;
  if FWorldArray.Item[AX, AY] = 1 then
    Result := True;
end;

procedure TsmWorld.StartGame;
begin
  FWorldArray := TsmWorldObj.Create;

  FUpdateTimer := TsmTimer.Create(self);
  FDrawPanel := TsmDrawPanel.Create(FMainElement);
  FDrawPanel.Name := 'drawpanel';
  FDrawPanel.Width := 31 * 16;
  FDrawPanel.Height := 480;

  FResources := TsmResources.Create(FDrawPanel);
  FResources.OnLoadEnd := @NotifyLoadEnd;
  FResources.Load('');

  window.addEventListener('keydown', @KeyDownHandler);
  window.addEventListener('keyup', @KeyUpHandler);
end;

procedure TsmWorld.CheckFall;
var
  val: integer;
  valD: integer;
begin
  valD := FWorldArray.Item[FPlayer.X, FPlayer.Y + 1];
  val := FWorldArray.Item[FPlayer.X, FPlayer.Y];
  if val = 0 then
    if (valD = 0) or (valD = 4) then
      FPlayerFall := True;
end;

procedure TsmWorld.CheckGold;
begin
  if FWorldArray.Item[FPlayer.X, FPlayer.Y] = 7 then
  begin
    //    Writeln('Gold');
    Dec(FGoldCount);
    FWorldArray.Item[FPlayer.X, FPlayer.Y] := 0;
  end;
end;

procedure TsmWorld.CheckHole;
var
  hole: TsmHole;
  rhole: TsmSprite;
begin
  if FDig then
  begin
    FDigHoleSprite.Update(0);
    FDigHoleSprite.Draw(FDrawPanel.Context);
  end;
  //  Writeln(FHoleList.Count);

  for hole in FHoleList do
  begin
    hole.Time := hole.Time - 1;
    if hole.Time = 0 then
    begin
      StartRestoreHole(hole.X, hole.Y);
      // FWorldArray.Item[hole.x, hole.y] := 1;
      FHoleList.Remove(hole);
      hole.Free;
    end;
  end;
  for rhole in FDigRestoreSpriteList do
  begin
    rhole.Update(0);
    rhole.Draw(FDrawPanel.Context);
  end;
end;

procedure TsmWorld.StartRestoreHole(AX, AY: integer);
var
  spr: TsmSprite;
begin
//  writeln('restore');
  spr := TsmSprite.Create(self, FResources.Dig);
  spr.Camera := FCamera;
  spr.StartFrame := 10;
  spr.FrameSize := 16;
  spr.FrameCount := 5;
  spr.AnimationTime := 0.05;
  spr.Animate := True;
  spr.X := AX * FRAME_SIZE;
  spr.Y := AY * FRAME_SIZE;
  spr.OnEndFrame := @EndRestoreHoleHandle;
  FDigRestoreSpriteList.Add(spr);
end;

procedure TsmWorld.LoadEndHandler(Sender: TObject);
begin

end;

procedure TsmWorld.DrawTimer(Sender: TObject);
begin
  FDrawPanel.Clear;
  CheckHole;
  DrawMap;

  MovePlayer;
  CheckGold;
  FPlayer.Update;
  FPlayer.Draw(FDrawPanel.Context);
  FEnemyManager.Update;
  FEnemyManager.Draw(FDrawPanel.Context);

//  FDrawPanel.Context.fillStyle := '#00F';
//  FDrawPanel.Context.strokeStyle := '#F00';
//  FDrawPanel.Context.font := 'italic 10pt Arial';
//  FDrawPanel.Context.fillText(IntToStr(FGoldCount), 10, 20);
//  FDrawPanel.Context.fillStyle := '#F0F';
//  FDrawPanel.Context.fillText(IntToStr(FWorldArray.Item[FPlayer.X, FPlayer.Y]), 10, 40);

  if FPlayer.AbsX + FCamera.X > (VISIBLE_CELL - OFFSET_CELL) * FRAME_SIZE then
    FCamera.x := trunc((VISIBLE_CELL - OFFSET_CELL) * FRAME_SIZE - FPlayer.AbsX);
  if FPlayer.AbsX + FCamera.X < OFFSET_CELL * FRAME_SIZE then
    FCamera.x := trunc(OFFSET_CELL * FRAME_SIZE - FPlayer.AbsX);
  if FCamera.x > -8 then
    FCamera.X := -8;
  if FCamera.x < -1 * VISIBLE_CELL * FRAME_SIZE + FRAME_SIZE then
    FCamera.X := -1 * VISIBLE_CELL * FRAME_SIZE + FRAME_SIZE;
end;

procedure TsmWorld.EndDigHandle(Sender: TObject);
begin
//  Writeln('End Dig');
  FDig := False;
  //  FDigHoleSprite.Animate := False;

end;

procedure TsmWorld.EndRestoreHoleHandle(Sender: TObject);
begin
//  writeln('End restore');
  FDigRestoreSpriteList.Remove(TsmSprite(Sender));
  FWorldArray.Item[round(TsmSprite(Sender).X / FRAME_SIZE), round(TsmSprite(Sender).Y / FRAME_SIZE)] := 1;
  //Sender.Free;
end;

function TsmWorld.KeyDownHandler(aEvent: TJSKeyBoardEvent): boolean;
begin
  if aEvent._repeat then
    Exit;
  case LowerCase(aEvent.Key) of
    'arrowright': begin
      FPressedKey := FPressedKey + [pkRight];
    end;
    'arrowleft': begin
      FPressedKey := FPressedKey + [pkLeft];
    end;
    'arrowup': begin
      FPressedKey := FPressedKey + [pkUp];
    end;
    'arrowdown': begin
      FPressedKey := FPressedKey + [pkDown];
    end;
    'End': begin
      //      FDigHoleSprite.;
      //      FPlayer.Die;
    end;
    'z': begin
      FPressedKey := FPressedKey + [pkDigLeft];
      //FPlayer.X := FPlayer.X;
      //      FDigLeft := True;
    end;
    'x': begin
      FPressedKey := FPressedKey + [pkDigRight];
      //FPlayer.X := FPlayer.X;
      //      FDigRight := True;
    end;

  end;
  // writeln(aEvent.Key);
end;

function TsmWorld.KeyUpHandler(aEvent: TJSKeyBoardEvent): boolean;
begin
  if aEvent._repeat then
    Exit;
  case LowerCase(aEvent.Key) of
    'arrowright': begin
      FPressedKey := FPressedKey - [pkRight];
    end;
    'arrowleft': begin
      FPressedKey := FPressedKey - [pkLeft];
    end;
    'arrowup': begin
      FPressedKey := FPressedKey - [pkUp];
    end;
    'arrowdown': begin
      FPressedKey := FPressedKey - [pkDown];
    end;
    'z': begin
      FPressedKey := FPressedKey - [pkDigLeft];
    end;
    'x': begin
      FPressedKey := FPressedKey - [pkDigRight];
    end;

  end;
end;

constructor TsmWorld.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := 'application';
  FMainElement := TsmComponent.Create(nil);
  FMainElement.Name := Name;
  FWorldWidth := 30;
  FWorldHeight := 15;
  FHoleList := TsmHoleList.Create;
  FHoleList.Clear;
  FCamera := TsmCamera.Create;
  FCamera.X := -8;
  FPlayerDie := False;
  FDig := False;
  FPlayerFall := False;
end;

destructor TsmWorld.Destroy;
begin
  FreeAndNil(FHoleList);
  FreeAndNil(FEnemyManager);
  FreeAndNil(FWorldArray);
  FreeAndNil(FUpdateTimer);
  FreeAndNil(FPlayer);
  FreeAndNil(FWorldSprite);
  FreeAndNil(FDrawPanel);
  FreeAndNil(FCamera);
  FreeAndNil(FMainElement);
  inherited Destroy;
end;

procedure TsmWorld.Start;
begin
  StartGame;
end;

end.
