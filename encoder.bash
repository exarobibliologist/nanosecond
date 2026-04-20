#!/bin/bash

function encoder()
{
ffmpeg -i $1 -acodec aac -aq 100 -ac 2 -vcodec libx264 -crf 24 -threads 0 $2
}
