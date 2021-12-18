unit timer;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, web;

type

  { TsmTimer }

  TsmTimer = class(TComponent)
  private
    FActive: boolean;
    FInterval: integer;
    FOnTimer: TNotifyEvent;
    FTimerHandle: nativeint;
    procedure SetActive(AValue: boolean);
    procedure TimerHandler;
  public
    constructor Create(AOwner: TComponent);
    property Interval: integer read FInterval write FInterval;
    property Active: boolean read FActive write SetActive;
    property OnTimer: TNotifyEvent read FOnTimer write FOnTimer;
  end;

implementation

{ TsmTimer }

procedure TsmTimer.SetActive(AValue: boolean);
begin
  if FActive = AValue then
    Exit;
  FActive := AValue;
  if FActive then
    FTimerHandle := window.setInterval(@TimerHandler, FInterval)
  else
  begin
    window.clearInterval(FTimerHandle);
    FTimerHandle := -1;
  end;
end;

procedure TsmTimer.TimerHandler;
begin
  if Assigned(OnTimer) then
    OnTimer(Self);
end;

constructor TsmTimer.Create(AOwner: TComponent);
begin
  FInterval := 1000;
  FActive := False;
end;

end.
