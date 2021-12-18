unit camera;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils;

type

  { TsmCamera }

  TsmCamera = class
  private
    FX: integer;
    FY: integer;
  public
    constructor Create;
    property X: integer read FX write FX;
    property Y: integer read FY write FY;
  end;

implementation

{ TsmCamera }

constructor TsmCamera.Create;
begin
  fx := 0;
  FY := 0;
end;

end.
