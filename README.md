ROBLOX-RemoteModule
===================

ModuleScript for making client/server communication easier


I created this module a while ago to try and make use of RemoteEvents/Functions on ROBLOX a lot less of a pain.

This module does both Events and Functions.

RemoteEvents
------------

To create a RemoteEvent, it must be done serverside as such through a server Script:
```
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfEvent = modRemote:CreateEvent("NameOfEvent");
```

Both the client and server use the :Listen(function) method to handle the events.

Client-side:
```
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
function onNameOfEvent(...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Server-side:
```
local nameOfEvent = modRemote:GetEvent("NameOfEvent"); 
function onNameOfEvent(player, ...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Then to fire events, there are the following methods:

Client-Side (SendToServer)
```
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToServer("Hello, World!");
```

Server-Side (SendToPlayer, SendToAllPlayers, SendToPlayers)
```
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToPlayer(game.Players.Player1, "Hello, World!");
nameOfEvent:SendToAllPlayers("Hello, World!");
nameOfEvent:SendToPlayers({game.Players.Player1, game.Players.Player2}, "Hello, World!");
```


RemoteFunctions
---------------

To create a RemoteFunction, it must be done serverside as such through a server Script:
```
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfFunction = modRemote:CreateFunction("NameOfFunction");
```

Both the client and server use the :Callback(function) method to handle the function, remember that the callback must return a value.

Client-side:
```
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
function nameOfFunctionCallback(...)
 -- do things with args
 return "Hello, World!";
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Server-side:
```
local nameOfFunction = modRemote:GetFunction("NameOfFunction"); 
function nameOfFunctionCallback(player, ...)
 -- do things with args
 return "Hello, there " .. player.Name .. "!';
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Then to fire events, there are the following methods:

Client-Side (SendToServer)
```
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallServer("Hello, World!");
print(returned);
```

Server-Side (CallServer)
```
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallServer("Hi Server!");
print(returned)
```
