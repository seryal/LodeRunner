unit camera;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils;

type

  { TsmCamera }

  TsmCamera = class
  private
  public
    constructor Create;
    property X: Integer read FX write FX;
    property Y: Integer read FY write FY;
  end;

implementation

{ TsmCamera }

constructor TsmCamera.Create;
begin

end;

end.
