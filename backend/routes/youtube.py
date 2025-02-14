from fastapi import APIRouter, Query
from pydantic import BaseModel
from youtubesearchpython import VideosSearch

router=APIRouter()

class VideoDetails(BaseModel):
    id:str
    title:str
    thumbnail:str

@router.get("/search-videos")
async def search_videos(query: str = Query(..., description="Search term for YouTube videos"), max_results: int = 10)->list[VideoDetails]:
    videosSearch = VideosSearch(query, limit = max_results)
    videos=[]
    for video in videosSearch.result()['result']:
        v=VideoDetails(id=video['id'],title=video['title'],thumbnail=video["thumbnails"][0]["url"])
        videos.append(v)
    return videos
        