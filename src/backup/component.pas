unit component;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, web;

type

  { TsmComponent }

  TsmComponent = class(TComponent)
  private
    FElement: TJSHTMLElement;
    FHeight: integer;
    FLeft: integer;
    FTop: integer;
    FWidth: integer;
    procedure SetHeigth(AValue: integer);
    procedure SetLeft(AValue: integer);
    procedure SetName(const NewName: TComponentName); override;
    procedure SetTop(AValue: integer);
    procedure SetWidth(AValue: integer);
  public
    constructor Create(AOwner: TsmComponent; AName: string); virtual;
    constructor Create(AOwner: TsmComponent); virtual;
    property HTMLElement: TJSHTMLElement read FElement;
    property Width: integer read FWidth write SetWidth;
    property Height: integer read FHeight write SetHeigth;
    property Left: integer read FLeft write SetLeft;
    property Top: integer read FTop write SetTop;
  end;

implementation

{ TsmComponent }

procedure TsmComponent.SetName(const NewName: TComponentName);
begin
  inherited SetName(NewName);
  FElement.id := NewName;
end;

procedure TsmComponent.SetTop(AValue: integer);
begin
  if FTop = AValue then Exit;
  FTop := AValue;
  HTMLElement.setAttribute('top', AValue.ToString + 'px');
end;

procedure TsmComponent.SetHeigth(AValue: integer);
begin
  if FHeight = AValue then Exit;
  FHeight := AValue;
  HTMLElement.setAttribute('height', AValue.ToString + 'px');
end;

procedure TsmComponent.SetLeft(AValue: integer);
begin
  if FLeft = AValue then Exit;
  FLeft := AValue;
  HTMLElement.setAttribute('left', AValue.ToString + 'px');
end;

procedure TsmComponent.SetWidth(AValue: integer);
begin
  if FWidth = AValue then Exit;
  FWidth := AValue;
  HTMLElement.setAttribute('width', AValue.ToString + 'px');
end;

constructor TsmComponent.Create(AOwner: TsmComponent; AName: string);
begin
  inherited Create(AOwner);
  if AName = '' then
    AName := 'div';
  FElement := TJSHTMLElement(document.createElement(AName));
  if Assigned(AOwner) then
    AOwner.HTMLElement.append(FElement)
  else
    document.body.append(FElement);
end;

constructor TsmComponent.Create(AOwner: TsmComponent);
begin
  Create(AOwner, '');
end;

end.
