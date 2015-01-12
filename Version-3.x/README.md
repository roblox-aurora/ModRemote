ModuleRemote
===================

ModuleScript for allowing easy creation/use of the RemoteFunction/RemoteEvent instances through ROBLOX lua scripting.


I created this module a while ago to try and make use of RemoteEvents/Functions on ROBLOX a lot less of a pain to work with.

This module does both Events and Functions.

RemoteEvents
------------

To create a RemoteEvent, it must be done serverside as such through a server Script:
```lua
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfEvent = modRemote:CreateEvent("NameOfEvent");
```

Both the client and server use the :Listen(function) method to handle the events.

Client-side:
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
function onNameOfEvent(...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Server-side:
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent"); 
function onNameOfEvent(player, ...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Then to fire events, there are the following methods:

Client-Side (SendToServer)
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToServer("Hello, World!");
```

Server-Side (SendToPlayer, SendToAllPlayers, SendToPlayers)
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToPlayer(game.Players.Player1, "Hello, World!");
nameOfEvent:SendToAllPlayers("Hello, World!");
nameOfEvent:SendToPlayers({game.Players.Player1, game.Players.Player2}, "Hello, World!");
```


RemoteFunctions
---------------

To create a RemoteFunction, it must be done serverside as such through a server Script:
```lua
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfFunction = modRemote:CreateFunction("NameOfFunction");
```

Both the client and server use the :Callback(function) method to handle the function, remember that the callback must return a value.

Client-side:
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
function nameOfFunctionCallback(...)
 -- do things with args
 return "Hello, World!";
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Server-side:
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction"); 
function nameOfFunctionCallback(player, ...)
 -- do things with args
 return "Hello, there " .. player.Name .. "!";
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Then to fire events, there are the following methods:

Client-Side (CallServer)
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallServer("Hello, World!");
print(returned);
```

Server-Side (CallPlayer)
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallPlayer(game.Players.Player1, "Hi Server!");
print(returned)
```



RemoteFunction Caching
---------------
Firing a RemoteFunction requires not only the client to send the server information, but the server to send the client information back.

If you want to cache this information in case you're not wanting to clog up the network with the same request - you can do the following:

Server-Side
```lua
local nameOfFunction = modRemote:CreateFunction("NameOfFunction");
nameOfFunction:SetClientCache(5);

nameOfFunction:Callback(function(player, number)
 return ("%d %d"):format(os.time(), number);
end);
```

Then on the client-side, you can try this out by doing:
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
for i = 1,30 do
 print(i, nameOfFunction:CallServer(i));
 wait(1);
end
```

You will notice it will return the same result for every 5 seconds this for-loop runs - the result of this is, that it only fired the RemoteFunction 7 times as opposed to 30 - which really would clog the network up.


```
i Time       i (server)
1 1421043208 1
2 1421043208 1
3 1421043208 1
4 1421043208 1
5 1421043213 5
6 1421043213 5
7 1421043213 5
8 1421043213 5
9 1421043213 5
10 1421043218 10
11 1421043218 10
12 1421043218 10
13 1421043218 10
14 1421043218 10
15 1421043223 15
16 1421043223 15
17 1421043223 15
18 1421043223 15
19 1421043223 15
20 1421043228 20
21 1421043228 20
22 1421043228 20
23 1421043228 20
24 1421043228 20
25 1421043233 25
26 1421043233 25
27 1421043233 25
28 1421043233 25
29 1421043233 25
30 1421043238 30
```

The following will not work as intended, however:
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local someValue = nameOfFunction:CallServer("GetSomeValue");
local anotherValue = nameOfFunction:CallServer("GetAnotherValue");
```
This means if you're using the same RemoteFunction for multiple "actions", you might want to separate the "actions" into individual RemoteFunctions. Using the same RemoteFunction for multiple "actions" is regarded as bad practice.


Working with existing RemoteEvents/RemoteFunctions
================
If you don't want to use ModRemote to create Events/Functions, you can wrap ModRemote around existing events/functions and use the library on them just as you would with ModRemote Events/Functions

Both of the following work server and client-side.

Once you use GetEventFromInstance/GetFunctionFromInstance - it will work just like if you used GetEvent/GetFunction.

RemoteEvents
--------------
(Example client using event)
```lua
local existingEvent = modRemote:GetEventFromInstance(path_to_event);
existingEvent:SendToServer("I'm firing a non-ModRemote instance using ModRemote methods! :D");
```

RemoteFunctions
--------------
(Example client using function)
```lua
local existingFunction = modRemote:GetFunctionFromInstance(path_to_function);
local test = existingFunction:CallServer("Test");
print(test);
```
