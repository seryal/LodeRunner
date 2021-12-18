unit resources;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, component, web, texture, tilemap, js, Generics.Collections;

type


  { TsmResources }

  TsmResources = class(TsmComponent)
  private
    FResourceCount: integer;
    FLoadedResourceCount: integer;
    FMap: TsmTileMap;
    FOnLoadEnd: TNotifyEvent;
    FPlayer: TsmTexture;
    FTile: TsmTexture;
    FDig: TsmTexture;
    FTextureList: TTextureList;
    procedure LoadMap(Sender: TObject);
    procedure LoadNotify(Sender: TObject);
  public
    constructor Create(AOwner: TsmComponent); override;
    procedure Load(APath: string);
    property Player: TsmTexture read FPlayer write FPlayer;
    property Tile: TsmTexture read FTile write FTile;
    property Map: TsmTileMap read FMap write FMap;
    property Dig: TsmTexture read FDig write FDig;
    property OnLoadEnd: TNotifyEvent read FOnLoadEnd write FOnLoadEnd;
  end;

implementation

{ TsmResources }

procedure TsmResources.LoadNotify(Sender: TObject);
begin
  Inc(FLoadedResourceCount);
  if FLoadedResourceCount >= FResourceCount then
    if Assigned(OnLoadEnd) then
      OnLoadEnd(Self);
end;

procedure TsmResources.LoadMap(Sender: TObject);
var
  js: TJSArray;
  tilename: string;
begin
  js := TJSArray(FMap.Map.Properties['tilesets']);
  tilename := string(TJSObject(js[0]).Properties['image']);
  FTile := TsmTexture.Create(Self);
  FTile.OnLoad := @LoadNotify;
  FTile.Src := tilename;

end;

constructor TsmResources.Create(AOwner: TsmComponent);
begin
  inherited Create(AOwner);
  FResourceCount := 3;
end;

procedure TsmResources.Load(APath: string);
begin

  FLoadedResourceCount := 0;
  FPlayer := TsmTexture.Create(Self);
  FPlayer.Src := 'assets/images/player.png';
  FPlayer.OnLoad := @LoadNotify;

  FDig := TsmTexture.Create(Self);
  FDig.Src := 'assets/images/dig.png';
  FDig.OnLoad := @LoadNotify;


  FMap := TsmTileMap.Create('/assets/levels/level1.json');
  FMap.OnLoaded := @LoadMap;
  //  TJSHTMLImageElement(FTexture).onload := @LoadHandler;
  //  FTexture.Name := 'smb_enemies_sheet';
end;

end.
