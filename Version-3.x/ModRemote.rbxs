--[[
	ModRemote v2.0
		ModuleScript for handling networking via client/server
]]
-- Main variables
local replicated = game:GetService("ReplicatedStorage");
local server = game:FindService("NetworkServer");
local remoteStorage = script;

local functionStorage = remoteStorage:FindFirstChild("Functions") or Instance.new("Configuration",remoteStorage);
functionStorage.Name = "Functions";

local eventStorage = remoteStorage:FindFirstChild("Events") or Instance.new("Configuration",remoteStorage);
eventStorage.Name = "Events";

local filtering = workspace.FilteringEnabled;
local localServer = (game.JobId == '');

local client = not server;
local remote = {
	Events = {};
	Functions = {};

	event = {};
	
	func = {};
	
	internal = {};
	Version = 3.01;
	
	--- Change this to true if you want to hide the warning.
	--- Do so at your OWN RISK.
	HideFilteringWarning = false;
	
	AllowExperimentalFeatures = true;
};

local remoteMT = {
	__index = (function(self, i)
		if (rawget(self.event, i)) then
			return rawget(self.event, i);
		else
			return rawget(self, i);
		end
	end);
};



-- This warning will only show on the server
if (not filtering and server and not remote.HideFilteringWarning) then
	warn("[ModRemote] ModRemote is running without Filtering, which is not recommended.");
	print("[ModRemote] Events/Functions created by this module can be changed/deleted by clients",
			"this makes your game vulnerable to exploits. If this is an old game, ignore this message.");
	
end

if (script.Parent ~= game:GetService("ReplicatedStorage")) then
	error("[ModRemote] Parent of Module should be ReplicatedStorage.");
end






--======================================= R E M O T E    E V E N T ========================================
function remote.internal:CreateEventMetatable(instance)
	local _event = {
		Instance = instance;
	};
	local _mt = {
		__index = (function(self, i)
			if (rawget(remote.event,i) ~= nil) then
				return rawget(remote.event,i);
			else
				return rawget(self, i);
			end
		end);
		__newindex = nil;
	};
	setmetatable(_event, _mt);
	
	return _event;	
end


function remote.internal:CreateEvent(name)
	
	local instance = eventStorage:FindFirstChild(name) or Instance.new("RemoteEvent", eventStorage);
	instance.Name = name;
	
	local _event = remote.internal:CreateEventMetatable(instance);
	
	remote.Events[name] = _event;
	
	return _event;
end


function remote:GetEventFromInstance(instance)
	local _event = remote.internal:CreateEventMetatable(instance);
	
	return _event;
end


function remote.internal:GetEvent(name)
	local ev =  (eventStorage:FindFirstChild(name));
	
	return ev;
end

--- Creates an event 
-- @param string name - the name of the event.
function remote:CreateEvent(name)
	if (not server) then
		warn("[ModRemote] CreateEvent should be used by the server."); end
	
	return remote.internal:CreateEvent(name);
end



--- Gets an event if it exists, otherwise errors
-- @param string name - the name of the event.
function remote:GetEvent(name)
	assert(type(name) == 'string', "[ModRemote] GetEvent - Name must be a string");
	assert(eventStorage:FindFirstChild(name),"[ModRemote] GetEvent - Event " .. name .. " not found, create it using CreateEvent.");
	
	local _event = remote.Events[name];
	if (_event) then
		return _event;
	else
		local _ev = remote.internal:CreateEvent(name);
		return _ev;
	end
end

do --[[EVENT OBJECT METHODS]]
	local remEnv = remote.event;
	
	function remEnv:SendToPlayers(playerList, ...) 
		assert(server, "[ModRemote] SendToPlayers should be called from the Server side.");
		for _, player in pairs(playerList) do
			self.Instance:FireClient(player, ...);
		end	
	end
	
	function remEnv:SendToPlayer(player, ...)  
		assert(server, "[ModRemote] SendToPlayers should be called from the Server side.");
		self.Instance:FireClient(player, ...);
	end
	
	function remEnv:SendToServer(...) 
		assert(client, "SendToServer should be called from the Client side.");
		self.Instance:FireServer(...);
	end
	
	function remEnv:SendToAllPlayers(...) 
		assert(server, "[ModRemote] SendToPlayers should be called from the Server side.");
		self.Instance:FireAllClients(...);	
	end
	
	function remEnv:Listen(func)
		if (server) then
			self.Instance.OnServerEvent:connect(func);
		else
			self.Instance.OnClientEvent:connect(func);
		end
	end
	
	function remEnv:Wait()
		if (server) then
			self.Instance.OnServerEvent:wait();
		else
			self.Instance.OnClientEvent:wait();
		end	
	end
	
	function remEnv:GetInstance() 
		return self.Instance; 
	end
	
	function remEnv:Destroy() 
		self.Instance:Destroy();	
	end
end

--====

function remote.internal:GetFunction(name)
	return (functionStorage:FindFirstChild(name));
end


function remote.internal:CreateFunction(name)
	
	local instance = functionStorage:FindFirstChild(name) or Instance.new("RemoteFunction", functionStorage);
	instance.Name = name;
	
	local _event = {
		Name = name;
		Instance = instance;
	};
	local _mt = {
		__index = (function(self, i)
			if (rawget(remote.func,i) ~= nil) then
				return rawget(remote.func,i);
			else
				return rawget(self, i);
			end
		end);
		__newindex = nil;
	};
	setmetatable(_event, _mt);
	
	remote.Events[name] = _event;
	
	return _event;
end

--- Gets a function if it exists, otherwise errors
-- @param string name - the name of the function.
function remote:GetFunction(name)
	assert(type(name) == 'string', "[ModRemote] GetFunction - Name must be a string");
	assert(functionStorage:FindFirstChild(name),"[ModRemote] GetFunction - Function " .. name .. " not found, create it using CreateFunction.");
	
	local _event = remote.Functions[name];
	if (_event) then
		return _event;
	else
		local _ev = remote.internal:CreateFunction(name);
		return _ev;
	end
end

--- Creates a function
-- @param string name - the name of the function.
function remote:CreateFunction(name)
	if (not server) then
		warn("[ModRemote] CreateFunction should be used by the server."); end
	
	return remote.internal:CreateFunction(name);
end






--======== REMOTE FUNCTION ===========
	
function remote:CallServer(name, ...)
	local instance = self.internal:GetFunction(name);
	assert(not server, "[ModRemote] CallServer should be called from the client side.");
	assert(instance, "[ModRemote] CallServer - Function " .. name .. " does not exist."); 	
	
	local response = instance:InvokeServer(...);
	return response;
end

function remote:CallPlayer(name, player, ...)
	local instance = self.internal:GetFunction(name);
	assert(server, "[ModRemote] CallPlayer should be called from the Server side.");
	assert(instance, "[ModRemote] CallPlayer - Function " .. name .. " does not exist."); 	
	
	
	local args = {...};
	local attempt, err = pcall(function()
		local response = instance:InvokeClient(player, unpack(args));
		return response;
	end);
	
	if (not attempt) then
		warn("[ModRemote] CallPlayer - Failed to recieve response from client " .. tostring(player));
		
		return nil;
	end
end

function remote:Callback(name, func)
	local instance = self.internal:GetFunction(name);
	assert(instance, "[ModRemote] Callback - Function " .. name .. " does not exist."); 

	if (server) then
		instance.OnServerInvoke = func;
	else
		instance.OnClientInvoke = func;
	end
end


function remote:DestroyFunction(name)
	local instance = self.internal:GetFunction(name);
	assert(instance, "[ModRemote] DestroyFunction - Function " .. name .. " does not exist."); 
	instance:Destroy();
end


--- Remote Function Methods
local remFunc = remote.func;
function remFunc:CallPlayer(...) return remote:CallPlayer(self.Name, ...); end
function remFunc:Callback(...) remote:Callback(self.Name, ...); end
function remFunc:GetInstance() return self.Instance; end
function remFunc:Destroy() remote:DestroyFunction(self.Name); end

if (remote.AllowExperimentalFeatures) then
	local tempCache = {};

	--- Sets the amount of seconds the client should cache a result from the server
	function remFunc:SetClientCache(seconds)
		seconds = seconds or 10;
		assert(server, "SetClientCache must be called on the server.");
		local instance = self:GetInstance();
		
		if (seconds == false or seconds < 1) then
			local cache = instance:FindFirstChild("ClientCache");
			if (cache) then
				cache:Destroy();
			end
		else
			local cache = instance:FindFirstChild("ClientCache") or Instance.new("IntValue", instance);
			cache.Name = "ClientCache";
			cache.Value = seconds;
		end
	end
	
	--[[
		TODO: Cache based on same params [?]
	--]]	
	
	function remFunc:CallServer(...) 
		local clientCache = self:GetInstance():FindFirstChild("ClientCache");
		if (clientCache) then
			local cached = tempCache[self.Name];
			if (cached and os.time() < cached.Expires) then
				return cached.Value;
			else
				local newVal = remote:CallServer(self.Name, ...);
				tempCache[self.Name] = {Expires = os.time() + clientCache.Value, Value = newVal};
				return newVal;
			end
		else
			return remote:CallServer(self.Name, ...);
		end
	end
	
else
	function remFunc:CallServer(...) 
		return remote:CallServer(self.Name, ...);  
	end
end


return remote;
