unit tilemap;

{$mode ObjFPC}

interface

uses
  Classes, SysUtils, js, web;

type

  { TsmTileMap }

  TsmTileMap = class(TPersistent)
  private
    FJSObject: TJSObject;
    FOnLoaded: TNotifyEvent;
    function LoadMapHandler(Event: TEventListenerEvent): boolean;
  public
    constructor Create(AFileName: string);
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property Map: TJSObject read FJSObject write FJSObject;
  end;

implementation

{ TsmTileMap }

function TsmTileMap.LoadMapHandler(Event: TEventListenerEvent): boolean;
var
  i: integer;
  jobj: TJSObject;
begin
//  writeln('loaded map');
  //writeln( TJSXMLHttpRequest(Event.target).responseText);
  FJSObject := TJSJSON.parseObject(TJSXMLHttpRequest(Event.target).responseText);
//  writeln(FJSObject.Properties['height']);

  for i := 0 to TJSArray(FJSObject.Properties['tilesets']).Length - 1 do
  begin
    jobj := TJSObject(TJSArray(FJSObject.Properties['tilesets'])[i]);
//    Writeln('==== ',jobj.Properties['image']);

  end;
  //Writeln(TJSArray(FJSObject.Properties['layers']).Length);


  if Assigned(OnLoaded) then
    OnLoaded(Self);

end;

constructor TsmTileMap.Create(AFileName: string);
var
  JSONHttpRequest: TJSXMLHttpRequest;
begin
  JSONHttpRequest := TJSXMLHttpRequest.new;
  JSONHttpRequest.addEventListener('load', @LoadMapHandler);
  JSONHttpRequest.Open('GET', AFileName, True);
  JSONHttpRequest.send;
//  Writeln('start load map');
end;

end.
