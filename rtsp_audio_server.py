#!/usr/bin/env python3

import gi
gi.require_version('Gst', '1.0')
gi.require_version('GstRtspServer', '1.0')
from gi.repository import Gst, GstRtspServer, GObject

Gst.init(None)

class AudioRTSPFactory(GstRtspServer.RTSPMediaFactory):
    def __init__(self):
        super().__init__()
        self.set_launch(
            'alsasrc device=plughw:0,0 ! audioconvert ! audioresample ! '
            'avenc_aac ! rtpmp4gpay pt=96 name=pay0'
        )
        self.set_shared(True)

class AudioRTSPServer:
    def __init__(self):
        self.server = GstRtspServer.RTSPServer()
        self.server.set_service("8554")
        factory = AudioRTSPFactory()
        self.server.get_mount_points().add_factory("/audio", factory)
        self.server.attach(None)

if __name__ == "__main__":
    print("RTSP audio server running at rtsp://<your-pi-ip>:8554/audio")
    AudioRTSPServer()
    loop = GObject.MainLoop()
    loop.run()
