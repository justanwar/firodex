#!/usr/bin/env python3
import sys
import json
import argparse
import requests
import zipfile
import io



def main():
    with open("build_config.json", "r") as f:
        data = json.load(f)

    data["api"]["api_commit_hash"] = args.api
    data["api"]["api_commit_branch"] = args.api_branch
    data["coins"]["bundled_coins_repo_commit"] = args.coins
    data["coins"]["coins_repo_branch"] = args.coins_branch

    # Get_checksums
    platforms = data["api"]["platforms"]
    # This does not work for some reason. 
    for p in platforms:
        break
        kw = platforms[p]["matching_keyword"]
        url = f"https://sdk.devbuilds.komodo.earth/{args.api_branch}/kdf_{args.api[:7]}-{kw}.zip.sha256"
        print(url)
        x = extract_hash(url, p)
        print(x)
        platforms[p]["valid_zip_sha256_checksums"] = [x]
        

    with open("build_config.json", "w") as f:
        data = json.dump(data, f, indent=4)


def extract_hash(url: str, p: str) -> str:
    try:
        r = requests.get(url)
        r.raise_for_status()
        if p == "windows":
            return r.text.splitlines()[3].split()[0]
        return r.text.splitlines()[0].split()[0]
    
    except requests.RequestException as e:
        print(f"An error occurred while downloading the {url}:", e)
    except IndexError:
        print(f"{url} appears to be empty.")
    except Exception as e:
        print(f"An unexpected error occurred for {url}:", e)
    return ""



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Updates build_config.json")
    # Optional arguments
    parser.add_argument("--api", help="commit hash of the API module to download.", required=True)
    parser.add_argument("--api_branch", help="branch of the API module to download.", default="dev", required=True)
    parser.add_argument("--coins", help="branch of the coins file to download.", required=True)
    parser.add_argument("--coins_branch", help="branch of the coins file to download.", default="master", required=True)
    args = parser.parse_args()
    main()