# ROBLOX-ModRemote
ModuleScript for making it easy to do Client/Server communication using the ROBLOX platform

You can create RemoteEvents/RemoteFunctions through this ModuleScript, or you can bind onto existing RemoteFunctions/RemoteEvents with ModRemote to use the ModRemote's API on them.


The ModuleScript is located [here](/ModRemote.rbxs).

RemoteEvents
============

To create a RemoteEvent, it must be done serverside as such through a server Script:
```lua
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfEvent = modRemote:CreateEvent("NameOfEvent");
```
You can also [Bind existing events manually](#working-with-existing-remoteeventsremotefunctions), and [Bind events in server scripts](#registering-eventsfunctions-parented-to-server-scriptsmodules)

Both the client and server use the :Listen(function) method to handle the events.

Client-side:
------------
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
function onNameOfEvent(...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Server-side:
------------
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent"); 
function onNameOfEvent(player, ...)
 -- do things with args
end
nameOfEvent:Listen(onNameOfEvent);
```

Then to fire events, there are the following methods:

Client-Side (SendToServer)
------------
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToServer("Hello, World!");
```

Server-Side (SendToPlayer, SendToAllPlayers, SendToPlayers)
------------
```lua
local nameOfEvent = modRemote:GetEvent("NameOfEvent");
nameOfEvent:SendToPlayer(game.Players.Player1, "Hello, World!");
nameOfEvent:SendToAllPlayers("Hello, World!");
nameOfEvent:SendToPlayers({game.Players.Player1, game.Players.Player2}, "Hello, World!");
```


RemoteFunctions
===============

To create a RemoteFunction, it must be done serverside as such through a server Script:
```lua
local replicatedStorage = game:GetService("ReplicatedStorage");
local modRemote = require(replicatedStorage.ModRemote);

local nameOfFunction = modRemote:CreateFunction("NameOfFunction");
```
You can also [Bind existing functions manually](#working-with-existing-remoteeventsremotefunctions), and [Bind functions in server scripts](#registering-eventsfunctions-parented-to-server-scriptsmodules)

Both the client and server use the :Callback(function) method to handle the function, remember that the callback must return a value.

Client-side:
------------
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
function nameOfFunctionCallback(...)
 -- do things with args
 return "Hello, World!";
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Server-side:
------------
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction"); 
function nameOfFunctionCallback(player, ...)
 -- do things with args
 return "Hello, there " .. player.Name .. "!";
end
nameOfFunction:Callback(nameOfFunctionCallback);
```

Then to invoke functions, there are the following methods:

Client-Side (CallServer)
------------
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallServer("Hello, World!");
print(returned);
```
or calling it like a function
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction("Hello, World!");
print(returned);
```

Server-Side (CallPlayer)
------------
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction:CallPlayer(game.Players.Player1, "Hi player!");
print(returned)
```
or calling it like a function
```lua
local nameOfFunction = modRemote:GetFunction("NameOfFunction");
local returned = nameOfFunction(game.Players.Player1, "Hi player!");
print(returned);
```




RemoteFunction Caching
======================
Firing a RemoteFunction requires not only the client to send the server information, but the server to send the client information back.

If you want to cache this information in case you're not wanting to clog up the network with the same request - you can do the following:

Server-Side
------------
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
However, if you're wanting to have it cache according to the first value - you can do the following:
```lua
local nameOfFunction = modRemote:CreateFunction("NameOfFunction");
nameOfFunction:SetClientCache(5, true);
```
The second argument is a boolean which determines whether or not the function should be cached depending on the first value of the call.


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


Registering Events/Functions parented to server scripts/modules
===============
e.g. 
![RemoteEvent parented to script](http://i.imgur.com/0rLdVaq.png)

This feature is useful if you want to parent your RemoteEvents/RemoteFunctions to a script, so you can see what events/functions are associated with what particular script.

You can do it short-hand by requring ModRemote like so from a server script:
```lua
local modRemote = require(replicatedStorage.ModRemote)();
```

Or if you wish to do it manually, you can use 
```lua
modRemote:RegisterChildren();
```

or
```lua
modRemote:RegisterChildren(the_instance_with_the_remotes);
```

which will go through all the RemoteEvents/RemoteFunctions parented to the script that calls the method, or if there's a instance specified in the arguments - the RemoteEvents/RemoteFunctions in that instance - and turn them into ModRemote events/functions.

Then you can grab those through ModRemote, like in our example you can simply grab it after you register it as such:
```lua
local coolEvent = modRemote:GetEvent("CoolEvent");
```

This will work both on the client and on the server, simple as that.
