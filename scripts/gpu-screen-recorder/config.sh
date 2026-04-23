FPS=60
REPLAY_BUFFER=60
FORMAT=mkv

# gsr warning: gsr_video_encoder_vaapi_start: black bars have been added to the video because of a bug in AMD drivers/hardware. Record with h264 codec instead (-k h264) to get around this issue
# FAQ on https://git.dec05eba.com/gpu-screen-recorder/about/ says it is fixed in ffmpeg 8, TODO: test when ffmpeg gets updated
CODEC=h264
