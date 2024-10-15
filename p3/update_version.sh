#!/bin/bash


GITHUB_REPO_URL="https://github.com/enilcobrut/cjunker_iot.git"
LOCAL_REPO_DIR="cjunker_iot"
GITHUB_REPO_PATH="configs"
APP_VERSION="v2"

if ! command -v git &> /dev/null
then
    echo "Git is not installed. Installing git..."
    sudo apt-get update
    sudo apt-get install -y git
fi

if [ -d "$LOCAL_REPO_DIR" ]; then
    echo "Repository directory already exists. Pulling latest changes..."
    cd "$LOCAL_REPO_DIR"
    git pull
else
    echo "Cloning the GitHub repository..."
    git clone "$GITHUB_REPO_URL"
    cd "$LOCAL_REPO_DIR"
fi

GITHUB_USERNAME=$(git config user.name)
if [ -z "$GITHUB_USERNAME" ]; then
    echo "Git user.name is not set. Please enter your Git username:"
    read GITHUB_USERNAME
    git config user.name "$GITHUB_USERNAME"
fi

GITHUB_USER_EMAIL=$(git config user.email)
if [ -z "$GITHUB_USER_EMAIL" ]; then
    echo "Git user.email is not set. Please enter your Git email:"
    read GITHUB_USER_EMAIL
    git config user.email "$GITHUB_USER_EMAIL"
fi

echo "GITHUB_USERNAME: $GITHUB_USERNAME"
echo "GITHUB_USER_EMAIL: $GITHUB_USER_EMAIL"
echo "GITHUB_REPO_PATH: $GITHUB_REPO_PATH"

if [ -f "$GITHUB_REPO_PATH/deployment.yaml" ]; then
    echo "Found deployment.yaml in $GITHUB_REPO_PATH"
else
    echo "Error: deployment.yaml not found in $GITHUB_REPO_PATH"
    exit 1
fi

echo "Updating the application version to $APP_VERSION..."
sed -i "s/wil42\/playground:v[0-9]*/wil42\/playground:$APP_VERSION/g" "$GITHUB_REPO_PATH/deployment.yaml"

echo "Committing and pushing the changes to GitHub..."
git add "$GITHUB_REPO_PATH/deployment.yaml"
git commit -m "Update application version to $APP_VERSION"

echo "Pushing changes to GitHub..."
git push origin master

echo "Script execution completed."
