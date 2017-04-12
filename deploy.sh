#!/bin/sh

hexo clean
hexo generate
hexo deploy

# git add -A && git commit -m 'deploy the blog'
# git push origin master