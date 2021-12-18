program loderunner;

{$mode objfpc}

uses
  browserapp,
  JS,
  Classes,
  SysUtils,
  Web,
  world, tilemap, camera, enemymanager, common, component;
type

  { TMyApplication }

  TMyApplication = class(TBrowserApplication)
  private
    FWorld: TsmWorld;
    FHelp: TsmComponent;
  public
    destructor Destroy; override;
    procedure doRun; override;
  end;


  destructor TMyApplication.Destroy;
  begin
    FreeAndNil(FWorld);
    inherited Destroy;
  end;

  procedure TMyApplication.doRun;
  var
    str: String;
  begin
    str := '<b>LEFT</b> - Left Arrow Key<br>';
    str := str + '<b>RIGHT</b> - Right Arrow Key<br>';
    str := str + '<b>UP</b> - Up Arrow Key<br>';
    str := str + '<b>DOWN</b> - Down Arrow Key<br>';
    str := str + '<b>DIG LEFT</b> - Z Key<br>';
    str := str + '<b>DIG RIGHT</b> - X Key<br>';


    FHelp := TsmComponent.Create(nil);

    FHelp.HTMLElement.innerHTML:= str;
//    writeln('Do');
    FWorld := TsmWorld.Create(Self);
    FWorld.Start;
  end;

var
  Application: TMyApplication;

begin
  Application := TMyApplication.Create(nil);
  Application.Initialize;
  Application.Run;
end.
