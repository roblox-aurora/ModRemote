API
=============
ModRemote Core:
```
  ModRemote metamethod __call()
  void RegisterChildren()
  void RegisterChildren(Instance childrenOf)

  ModEvent CreateEvent(string eventName)
  ModEvent GetEvent(string eventName)
  ModEvent GetEventFromInstance(Instance remoteEvent)
  
  ModFunction CreateFunction(string funcName)
  ModFunction GetFunction(string funcName)
  ModFunction GetFunctionFromInstance(Instance remoteFunction)
```

ModEvent
```
[shared]
  void Listen(LuaFunction func) 
  [yields] void Wait() 
  
  void Destroy()
  void GetInstance()

[server]
  void SendToPlayer(Player player, ...)
  void SendToPlayers(Table players, ...)
  void SendToAllPlayers(...)

[client]
  void SendToServer(...)
```

ModFunction
```
[shared]
  void Callback(LuaFunction func)
  
  void Destroy()
  void GetInstance()
  
  

[server] 
  Result metamethod __call(Player player, ...)
  Result CallPlayer(Player player, ...)
  void SetClientCache(int seconds)

[client] 
  [cachable] 
    Result metamethod __call(...)
    Result CallServer(...)
```
