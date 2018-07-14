#!/usr/bin/env bash
# Made by The_Human
# bash script which converts audio format of video to mp3 using ffmpeg. made it to convert movies' audio codec to watch in tvs

read -e -p "enter the dir of the video: " input_file
read -e -p "enter the output dir of the video: " output_file
sudo ffmpeg -i ${input_file} -acodec mp3 -vcodec copy ${output_file}
