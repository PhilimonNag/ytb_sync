from fastapi import FastAPI,WebSocket
import uuid
from backend.routes import youtube
app=FastAPI()
users:dict[str,WebSocket]={}
rooms:dict[str,map]={}

app.include_router(router=youtube.router)
@app.websocket("/ws")
async def websoket(ws:WebSocket):
  try:
    await ws.accept()
    user_id=gen_id()
    users[user_id]=ws
    print(f"user:{user_id} connected")
    await ws.send_json({"event":"connection",
                  "msg":"connected successfully",
                  "data":{"user_id":user_id}})
    while True:
      data=await ws.receive_json()
      print(data)
      event=data["event"]
      payload=data["payload"]
      if event=="create_room":
        room_name=payload.get("room_name")
        host_id=payload.get("user_id")
        room_id=gen_id() 
        room={
          "id":room_id,
          "name":room_name,
          "host_id":host_id,
          "video_id":"Jer0FgPZj6w",
          "participants":[host_id]
        }
        rooms[room_id]=room
        await ws.send_json({"event":"create_room",
                     "data":{"msg":"room created",
                             "room":room}
                      })
      if event=="video_selected":
          room_id=payload["room_id"]
          video_id=payload["video_id"]
          rooms[room_id]["video_id"]=video_id
          for user_id in rooms[room_id]["participants"]:
              await users[user_id].send_json({
                 "event":"video_selected",
                 "data":{
                    "video_id":video_id,
                 }
              })
      
      if event=="video_state":
        room_id=payload["room_id"]
        video_id=payload["video_id"]
        is_playing=payload["is_playing"]
        seek_time=payload["seek_time"]
        if rooms[room_id]:
           rooms[room_id]["video_id"]=video_id
           rooms[room_id]["is_playing"]=is_playing
           rooms[room_id]["seek_time"]=seek_time
           for user in rooms[room_id]["participants"]:
              await users[user].send_json({"event":"video_state","data":payload})
           
      if event=="join_room":
         room_id=payload["room_id"]
         user_id=payload["user_id"]
         if rooms[room_id]:
            if user_id not in rooms[room_id]["participants"]:
               rooms[room_id]["participants"].append(user_id)
               for user in rooms[room_id]["participants"]:
                   if user_id!=user:
                     await users[user].send_json({
                        "event":"user_joined",
                        "data":{
                          "msg":f"{user_id} joined the room",
                          "participants":rooms[room_id]["participants"]
                        }
                    })
               
               await users[user_id].send_json({
                  "event":"room_joined",
                  "data":{
                     "msg":"Join room Successfulyy",
                     "room":rooms[room_id]
                  }
               })
          
         else:
            await users[user_id].send_json({
               "event":"room_not_found",
               "data":
               {
                  "msg":"Room Not Found"
               }
            })
  except Exception as e:
    print("WsErr: ",e)

def gen_id()->str:
  id = uuid.uuid4()
  return str(id).replace('-', '')[:16]