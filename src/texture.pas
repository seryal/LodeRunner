unit texture;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, component, web, Generics.Collections;

type

  { TsmTexture }

  TsmTexture = class(TsmComponent)
  private
    FHeight: integer;
    FOnLoad: TNotifyEvent;
    FSrc: string;
    FWidth: integer;
    function LoadHandler(Event: TEventListenerEvent): boolean;
    procedure SetSrc(AValue: string);
  public
    constructor Create(AOwner: TsmComponent); override;
    property Src: string read FSrc write SetSrc;
    property Width: integer read FWidth;
    property Height: integer read FHeight;
    property OnLoad: TNotifyEvent read FOnLoad write FOnLoad;
  end;

  TTextureList = specialize TList<TsmTexture>;


implementation

{ TsmTexture }

procedure TsmTexture.SetSrc(AValue: string);
begin
  if FSrc = AValue then Exit;
  FSrc := AValue;
  TJSHTMLImageElement(HTMLElement).onload := @LoadHandler;
  TJSHTMLImageElement(HTMLElement).src := AValue;
end;

function TsmTexture.LoadHandler(Event: TEventListenerEvent): boolean;
begin
  //Writeln('Image Load End');
  FWidth := TJSHTMLImageElement(HTMLElement).Width;
  FHeight := TJSHTMLImageElement(HTMLElement).Height;
  //writeln(FWidth, ' - ', FHeight);
  if Assigned(OnLoad) then
    OnLoad(Self);
end;

constructor TsmTexture.Create(AOwner: TsmComponent);
begin
  inherited Create(AOwner, 'img');
end;

end.
