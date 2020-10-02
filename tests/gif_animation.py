import numpy as np
from mango import (
    BBQContext, KernelFunction, UnitType, KernelBuilder,
    FileType, BufferBuilder, TaskGraph, BufferArg, 
    ScalarArg, ScalarType, EventArg, KernelArguments, EventBuilder
)
from tests.sample_wrappers.gif_saver.animated_gif_saver import GifSaver
import sys

frames = [
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,0,0,     255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,0,0,     255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,0,0,     255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    
    
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,0,0,     255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    
    
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    255,255,255, 255,0,0,     255,0,0,     255,0,0,     255,255,255,
    255,255,255, 255,0,0,     255,255,255, 255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,0,0,     255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    
    
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    255,255,255, 255,0,0,     255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,255,255, 255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,0,0,     255,255,255,
    255,255,255, 255,0,0,     255,0,0,     255,255,255, 255,255,255,
    255,255,255, 255,255,255, 255,255,255, 255,255,255, 255,255,255,
    ]

sx = 5
sy = 7
frame_size = sx*sy*3
out_frame_size = frame_size*4
gif_saver = GifSaver(sx*2, sy*2)

frames_matrix = np.array(frames, dtype=np.ubyte).reshape(4, frame_size)
out_frame = bytearray(out_frame_size)

ctx = BBQContext("gif_animation", "gif_animation")

scale_kernel_file  = "/opt/mango/usr/local/share/gif_animation/scale/scale_kernel"
smooth_kernel_file = "/opt/mango/usr/local/share/gif_animation/smooth/smooth_kernel"
copy_kernel_file   = "/opt/mango/usr/local/share/gif_animation/copy/copy_kernel"

kf_scale  = KernelFunction()
kf_copy   = KernelFunction()
kf_smooth = KernelFunction()
kf_copy.load(copy_kernel_file, UnitType.GN, FileType.BINARY)
kf_scale.load(scale_kernel_file, UnitType.GN, FileType.BINARY)
kf_smooth.load(smooth_kernel_file, UnitType.GN, FileType.BINARY)

bb1 = BufferBuilder(frame_size)
bb2 = BufferBuilder(out_frame_size)
bb3 = BufferBuilder(out_frame_size)

kbscale  = KernelBuilder(kf_scale, buffers_in=[bb1], buffers_out=[bb2])
kbcopy   = KernelBuilder(kf_copy, buffers_in=[bb2], buffers_out=[bb3])
kbsmooth = KernelBuilder(kf_smooth, buffers_in=[bb2], buffers_out=[bb3])

ebsync_e1 = EventBuilder([kbcopy, kbsmooth], [kbscale, kbcopy])

kscale  = ctx.register_kernel(kbscale)
kcopy   = ctx.register_kernel(kbcopy)
ksmooth = ctx.register_kernel(kbsmooth)

b1 = ctx.register_buffer(bb1)
b2 = ctx.register_buffer(bb2)
b3 = ctx.register_buffer(bb3)

sync_e1 = ctx.register_event(ebsync_e1)

tg = TaskGraph(
    kernels=[kscale, kcopy, ksmooth], 
    buffers=[b1, b2, b3],
    events=[sync_e1]
)

with ctx.resource_allocation(tg):
    arg1 = BufferArg(b1)
    arg2 = BufferArg(b2)
    arg3 = BufferArg(b3)
    arg_sx = ScalarArg(sx, ScalarType.INT)
    arg_sy = ScalarArg(sy, ScalarType.INT)
    arg_sx2 = ScalarArg(sx*2, ScalarType.INT)
    arg_sy2 = ScalarArg(sy*2, ScalarType.INT)
    arg_e1 = EventArg(sync_e1)

    args_scale  = KernelArguments(kscale, arg_e1, arg2, arg1, arg_sx, arg_sy)
    args_copy   = KernelArguments(kcopy, arg_e1, arg3, arg2, arg_sx2, arg_sy2)
    args_smooth = KernelArguments(ksmooth, arg_e1, arg3, arg2, arg_sx2, arg_sy2)

    for i in range(0, 4):
        b1.write(frames_matrix[i].tobytes())

        e1 = ctx.start_kernel(kscale, args_scale)
        e2 = ctx.start_kernel(kcopy, args_copy)
        e3 = ctx.start_kernel(ksmooth, args_smooth)

        e1.wait()
        e2.wait()
        e3.wait()

        b3.read(out_frame)

        gif_saver.add_frame(out_frame, i+1)


gif_saver.save("testgif.gif")

print("Done!")


