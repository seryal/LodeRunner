unit drawpanel;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, web, component;

type

  { TsmDrawPanel }

  TsmDrawPanel = class(TsmComponent)
  private
    FContext: TJSCanvasRenderingContext2D;
    function GetContext: TJSCanvasRenderingContext2D;
  public
    constructor Create(AOwner: TsmComponent); override;
    procedure Rectangle(x, y, Width, Height: integer);
    procedure Clear;
    property Context: TJSCanvasRenderingContext2D read GetContext;
  end;

implementation

{ TsmDrawPanel }

function TsmDrawPanel.GetContext: TJSCanvasRenderingContext2D;
begin
  if not Assigned(FContext) then
  begin
    FContext := TJSCanvasRenderingContext2D(TJSHTMLCanvasElement(HTMLElement).getContext('2d'));
    FContext.scale(2, 2);
    { TODO: https://gitlab.com/freepascal.org/fpc/pas2js/-/merge_requests/10 }
    asm
      this.FContext.imageSmoothingEnabled = false;
    end;
//    FContext.imageSmoothingEnabled := False;
  end;
  Result := FContext;
end;

constructor TsmDrawPanel.Create(AOwner: TsmComponent);
begin
  inherited Create(AOwner, 'canvas');
  HTMLElement.style.setProperty('position', 'absolute');
end;

procedure TsmDrawPanel.Rectangle(x, y, Width, Height: integer);
begin
  GetContext.rect(x, y, Width, Height);
  GetContext.fill;
end;

procedure TsmDrawPanel.Clear;
begin
  Left := 150;
  Top := 150;
  //  GetContext.clearRect(0, 0, HTMLElement.clientWidth, HTMLElement.clientHeight);
  GetContext.fillStyle := 'black';
  GetContext.fillRect(0, 0, HTMLElement.clientWidth, HTMLElement.clientHeight);
  //  GetContext.clearRect(0, 0, HTMLElement.clientWidth, HTMLElement.clientHeight);
end;

end.
