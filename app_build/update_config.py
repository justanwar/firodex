#!/usr/bin/env python3
import sys
import json
import argparse


def main():
    with open("build_config.json", "r") as f:
        data = json.load(f)
        data["api"]["api_commit_hash"] = args.api
        data["api"]["api_commit_branch"] = args.api_branch
        data["coins"]["bundled_coins_repo_commit"] = args.coins
        data["coins"]["coins_repo_branch"] = args.api_branch


    with open("build_config.json", "w") as f:
        data = json.dump(data, f, indent=4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Updates build_config.json")
    # Optional arguments
    parser.add_argument("--api", help="commit hash of the API module to download.", required=True)
    parser.add_argument("--api_branch", help="branch of the API module to download.", default="dev", required=True)
    parser.add_argument("--coins", help="branch of the coins file to download.", required=True)
    parser.add_argument("--coins_branch", help="branch of the coins file to download.", default="master", required=True)
    args = parser.parse_args()
    main()