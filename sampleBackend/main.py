import os
import time
import base64
from flask.json import load
import requests
import random
import json
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

CLIENT_ID = os.environ.get(
    'MAL_CLIENT_ID')  # Make sure your environment variable is set

access_token = None
refresh_token = None
isAdmin = False

NUM_ENTRIES_IN_PLAYLIST = 6


def get_english_title(anime_id, headers):
    url = f"https://api.myanimelist.net/v2/anime/{anime_id}?fields=alternative_titles"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        return data.get("alternative_titles", {}).get("en") or None
    return None


def get_top_rated_anime(username, per_page=100, max_pages=10):
    offset = 0
    all_scored_entries = []

    headers = {"X-MAL-CLIENT-ID": CLIENT_ID}

    for _ in range(max_pages):  # avoid infinite loop, cap pages
        url = f"https://api.myanimelist.net/v2/users/{username}/animelist?limit={per_page}&offset={offset}&fields=list_status&sort=list_score"

        start_time = time.time()
        response = requests.get(url, headers=headers)
        end_time = time.time()
        print(f"API request took {end_time - start_time:.2f} seconds")
        
        if response.status_code != 200:
            return {
                "error": f"Request failed: {response.status_code}",
                "details": response.text
            }

        data = response.json()
        entries = data.get("data", [])
        numberOfEntries = len(entries)
        
        if not entries:
            break  # No more data

        # Filter and collect scored entries
        for entry in entries:
            score = entry.get("list_status", {}).get("score", 0)
            if entry["node"][
                    "title"] == "Shingeki no Kyojin: The Final Season - Kanketsu-hen":
                continue
            if score > 0:
                all_scored_entries.append({
                    "id": entry["node"]["id"],
                    "title": entry["node"]
                    ["title"],  # Temporary, will replace with English title
                    "score": score
                })

        offset += per_page
        if numberOfEntries >= 100:
            break
            
        time.sleep(0.2)  # polite pause to avoid hammering API

        if len(entries) < per_page:
            break

    # Replace title with English title using individual anime lookups
    
    #for anime in all_scored_entries[:15]:
        #english_title = get_english_title(anime["id"], headers)
       # if english_title:
            #anime["title"] = english_title

        #time.sleep(0.1)  # small delay to respect rate limits

    return all_scored_entries


# Backend API endpoint
@app.route('/top_rated_anime', methods=['GET'])
def top_rated_anime_api():
    username = request.args.get('username')
    #username = "tonyisyh44"
    global isAdmin
    if username == "tonyisyh44":
        isAdmin = True
    else:
        isAdmin = False
        
    spotify_code = request.args.get('code')

    #print(spotify_code)
    #print()

    if not username:
        return jsonify({"error": "Username is required"}), 400

    result = get_top_rated_anime(username)
    fetch_access_token(spotify_code)
    load_tokens()

    result_jsonified = jsonify(result)
    json_data = result_jsonified.get_json()

    animeOPSpotifyLinks = []
    track_uris = []
    headers = {"X-MAL-CLIENT-ID": CLIENT_ID}

    numEntries = 0
    
    for anime in json_data:
        if numEntries >= NUM_ENTRIES_IN_PLAYLIST:
            break
            
        english_title = get_english_title(anime["id"], headers)
        anime["title"] = english_title
        track_info = search_track(english_title)
        
        if int(track_info["popularity"]) < 50:
            continue
        json_obj = {
            "anime_title": anime["title"],
            "song_name": track_info["name"],
            "song_url": track_info["spotify_url"],
            "popularity": track_info["popularity"]
        }
        animeOPSpotifyLinks.append(json_obj)
        track_uris.append(track_info["spotify_url"].replace("https://open.spotify.com/track/", "spotify:track:"))
        numEntries += 1

    #print(animeOPSpotifyLinks)
    
    playlist_data = create_spotify_playlist(access_token)
    
    add_songs_to_playlist(access_token, playlist_data["id"], track_uris)
    response = update_playlist_icon(access_token, playlist_data["id"], track_uris)
    if response is not None:
        print(result)
    
    return {"anime_playlist_url": playlist_data["external_url"]}
    #return animeOPSpotifyLinks


def create_spotify_playlist(access_token, playlist_name="My Anime Playlist", description="Top-rated anime OPs generated from MyAnimeListToPlaylist; created by Tony Chen"):
    url = "https://api.spotify.com/v1/me/playlists"
    headers = {"Authorization": f"Bearer {access_token}", "Content-Type": "application/json"}
    payload = {
        "name": playlist_name,
        "description": description,
        "public": True  # Set to True if you want the playlist to be public
    }

    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()  # Raise an error if the request fails
    playlist_data = response.json()

    return {
        "id": playlist_data["id"],
        "external_url": playlist_data["external_urls"]["spotify"]
    }


def add_songs_to_playlist(access_token, playlist_id, track_uris):
    track_uris = fisher_yates_shuffle(track_uris)
    url = f"https://api.spotify.com/v1/playlists/{playlist_id}/tracks"
    headers = {"Authorization": f"Bearer {access_token}"}
    payload = {"uris": track_uris}  # A list of URIs, e.g., ["spotify:track:track_id1", "spotify:track:track_id2"]

    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()  # Raise an error if the request fails
    return response.json()  # Return the response (optional, for logging or confirmation)
    

def update_playlist_icon(access_token, playlist_id, track_uri):
    randInt = random.randint(0, len(track_uri) - 1)
    track = track_uri[randInt]

    track_info = search_track_by_uri(track, access_token)  # Get track details using the track URI

    if "error" in track_info:
        print("Unable to retrieve track details")
        return {"error": "Track not found or unable to retrieve track details"}

    print("Setting album cover to: " + track_info["name"] + ", url=" + track_info["album_cover_url"])
    album_cover_url = track_info["album_cover_url"]

    # Convert base64 string back to binary for upload
    image_data = base64.b64encode(requests.get(album_cover_url).content)

    # Upload the image to Spotify
    url = f"https://api.spotify.com/v1/playlists/{playlist_id}/images"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "image/jpeg"
    }
    response = requests.put(url, headers=headers, data=image_data)

    if response.status_code != 202:
        return {
            "error": f"Failed to update playlist cover image. "
                     f"Status code: {response.status_code}, Response: {response.text}"
        }



def search_track_by_uri(track_uri, access_token):
    # Fetch track details using the Spotify track URI
    url = f"https://api.spotify.com/v1/tracks/{track_uri.split(':')[2]}"  # Extract track ID from URI
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        return {"error": "Unable to fetch track details"}

    track_info = response.json()

    # Extract necessary track info, including the album cover URL
    album_cover_url = track_info["album"]["images"][0]["url"]  # Use the first image (usually the largest)

    return {
        "name": track_info["name"],
        "album_cover_url": album_cover_url
    }

def search_track(track_name):
    headers = {"Authorization": f"Bearer {access_token}"}
    params = {"q": track_name, "type": "track", "limit": 1}

    #print("Searching for track:", track_name)
    
    response = safe_spotify_get("https://api.spotify.com/v1/search", headers, params)
    response.raise_for_status()
    results = response.json()

    if results["tracks"]["items"]:
        track = results["tracks"]["items"][0]
        return {
            "name": track["name"],
            "artist": track["artists"][0]["name"],
            "album": track["album"]["name"],
            "preview_url": track["preview_url"],
            "spotify_url": track["external_urls"]["spotify"],
            "popularity": track["popularity"]
        }
    else:
        return {"error": "No results found"}


def fetch_access_token(code):
    redirect_uri = 'https://tchenusc.github.io/myanimelistToPlaylist/'
    body = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri,
        "client_id": os.environ.get('SPOTIFY_CLIENT_ID'),
        "client_secret": os.environ.get('SPOTIFY_CLIENT_SECRET')
    }
    call_authorization_api(body)


TOKEN_URL = "https://accounts.spotify.com/api/token"


def call_authorization_api(body):
    client_id = os.environ.get('SPOTIFY_CLIENT_ID')
    client_secret = os.environ.get('SPOTIFY_CLIENT_SECRET')

    headers = {
        "Content-Type":
        "application/x-www-form-urlencoded",
        "Authorization":
        "Basic " +
        base64.b64encode(f"{client_id}:{client_secret}".encode()).decode()
    }

    response = requests.post(TOKEN_URL, data=body, headers=headers)
    handle_authorization_response(response)


def handle_authorization_response(response):
    global access_token, refresh_token

    if response.status_code == 200:
        data = response.json()
        access_token = data.get("access_token")
        refresh_token = data.get("refresh_token")

        #if isAdmin:
            #with open("tokens.json", "w") as token_file:
                #json.dump({
                    #"access_token": access_token,
                    #"refresh_token": refresh_token
                #}, token_file)
        
            #print("Tokens saved to tokens.json")

    else:
        print("Error:", response.text)
        # Optionally raise an exception or handle error

def fisher_yates_shuffle(arr):
    n = len(arr)
    for i in range(n - 1, 0, -1):
        j = random.randint(0, i)  # pick a random index from 0 to i
        arr[i], arr[j] = arr[j], arr[i]  # swap
    return arr

def load_tokens():
    global access_token, refresh_token
    try:
        with open("tokens.json", "r") as token_file:
            data = json.load(token_file)
            access_token = data.get("access_token")
            refresh_token = data.get("refresh_token")
            print("Tokens loaded from tokens.json")
    except FileNotFoundError:
        print("No saved tokens found.")

def refresh_access_token():
    global access_token, refresh_token

    client_id = os.environ.get('SPOTIFY_CLIENT_ID')
    client_secret = os.environ.get('SPOTIFY_CLIENT_SECRET')

    headers = {
        "Authorization": "Basic " + base64.b64encode(f"{client_id}:{client_secret}".encode()).decode(),
        "Content-Type": "application/x-www-form-urlencoded"
    }

    data = {
        "grant_type": "refresh_token",
        "refresh_token": refresh_token
    }

    response = requests.post(TOKEN_URL, headers=headers, data=data)

    if response.status_code == 200:
        token_data = response.json()
        access_token = token_data.get("access_token")

        # Spotify may not always return a new refresh token
        if "refresh_token" in token_data:
            refresh_token = token_data.get("refresh_token")

        # Save updated tokens
        with open("tokens.json", "w") as f:
            json.dump({
                "access_token": access_token,
                "refresh_token": refresh_token
            }, f)

        print("Access token refreshed and saved.")

    else:
        print("Failed to refresh token:", response.status_code, response.text)

def safe_spotify_get(url, headers, params=None):
    global access_token

    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 401:
        print("Access token expired, refreshing...")
        refresh_access_token()
        headers["Authorization"] = f"Bearer {access_token}"
        response = requests.get(url, headers=headers, params=params)

    return response

app.run(host='0.0.0.0', port=3000)
