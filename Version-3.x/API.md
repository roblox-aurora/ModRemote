API
=============
ModRemote Core:
```
  ModRemote __call()
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
[client]
  void SendToServer(...)

[server]
  void SendToPlayer(Player player, ...)
  void SendToPlayers(Table players, ...)
  void SendToAllPlayers(...)

[shared]
  void Listen(LuaFunction func) 
  [yields] void Wait() 
  
  void Destroy()
  void GetInstance()
```

ModFunction
```
[shared]
  void Callback(LuaFunction func)
  
  void Destroy()
  void GetInstance()

[client] 
  [cachable] 
    void CallServer(...)
[server] 
  void CallPlayer(Player player, ...)
  void SetClientCache(int seconds)
```
