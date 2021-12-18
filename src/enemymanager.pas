unit enemymanager;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, common, actor, resources, web;

type

  { TsmEnemyManager }

  TsmEnemyManager = class
  private
    FWorldArray: TsmWorldObj;
    FPlayer: TsmActor;
    FResources: TsmResources;
  public
    constructor Create(AWorldArray: TsmWorldObj; APlayer: TsmActor; AResources: TsmResources);
    destructor Destroy; override;
    procedure Update;
    procedure Show;
    procedure Draw(ACtx: TJSCanvasRenderingContext2D);
  end;

implementation

{ TsmEnemyManager }

constructor TsmEnemyManager.Create(AWorldArray: TsmWorldObj; APlayer: TsmActor; AResources: TsmResources);
begin
  FWorldArray := AWorldArray;
  FPlayer := APlayer;
  FResources := AResources;
end;

destructor TsmEnemyManager.Destroy;
begin
  inherited Destroy;
end;

procedure TsmEnemyManager.Update;
begin

end;

procedure TsmEnemyManager.Show;
begin

  //writeln('enemy - ', FWorldArray.Item[0, 0]);
end;

procedure TsmEnemyManager.Draw(ACtx: TJSCanvasRenderingContext2D);
begin

end;

end.
