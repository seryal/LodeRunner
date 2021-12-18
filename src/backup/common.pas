unit common;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, Generics.Collections;

const
  FPS = 60;
  VISIBLE_CELL = 15;
  OFFSET_CELL = 3;
  PLAYER_WALK_SPEED = 1.1;
  HOLE_LIFE_TIME = 100;

type
  TsmKey = (pkNone, pkLeft, pkRight, pkUp, pkDown, pkDigLeft, pkDigRight, pkPause);

  TsmHole = class
    X: integer;
    Y: integer;
    Time: double;
  end;

  TsmHoleList = specialize TList<TsmHole>;


  TsmWorldArray = array [0..29, 0..14] of byte;

  { TsmWorldObj }

  TsmWorldObj = class
  private
    FWorldArray: TsmWorldArray;
    function GetWorldArray(AX: integer; AY: integer): byte;
    procedure SetWorldArray(AX: integer; AY: integer; AValue: byte);
  public
    property Item[AX: integer; AY: integer]: byte read GetWorldArray write SetWorldArray;
  end;

implementation

{ TsmWorldObj }

function TsmWorldObj.GetWorldArray(AX: integer; AY: integer): byte;
begin
  Result := FWorldArray[AX, AY];
end;

procedure TsmWorldObj.SetWorldArray(AX: integer; AY: integer; AValue: byte);
begin
  FWorldArray[AX, AY] := AValue;
end;

end.
