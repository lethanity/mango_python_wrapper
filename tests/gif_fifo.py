import numpy as np
from mango import (
    BBQContext, KernelFunction, UnitType, KernelBuilder,
    FileType, BufferBuilder, TaskGraph, BufferArg, 
    ScalarArg, ScalarType, EventArg, KernelArguments,
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
out_frame_size = frames_matrix_size = frame_size*4
out_matrix_size = out_frame_size*4

gif_saver = GifSaver(sx*2, sy*2)

frames_matrix = np.array(frames, dtype=np.ubyte)
print(len(frames_matrix.tobytes()))
out_matrix = bytearray(out_frame_size*4)

#actual = frames_matrix.reshape(4, 105)
#[gif_saver.add_frame(actual[i], i+1) for i in range(0, 4)]
#gif_saver.save("testgif.gif")


ctx = BBQContext("gif_animation", "gif_animation")

kernel_file = "/opt/mango/usr/local/share/gif_fifo/scale/scale_kernel_fifo"

kf = KernelFunction()
kf.load(kernel_file, UnitType.GN, FileType.BINARY)

bb1 = BufferBuilder(frame_size, is_fifo=True)
bb2 = BufferBuilder(out_frame_size, is_fifo=True)

kb = KernelBuilder(kf, buffers_in=[bb1], buffers_out=[bb2])

k = ctx.register_kernel(kb)

b1 = ctx.register_buffer(bb1)
b2 = ctx.register_buffer(bb2)

tg = TaskGraph(
    kernels=[k], 
    buffers=[b1, b2]
)

with ctx.resource_allocation(tg):
    arg1 = BufferArg(b1)
    arg2 = BufferArg(b2)
    arg_sx = ScalarArg(sx, ScalarType.INT)
    arg_sy = ScalarArg(sy, ScalarType.INT)
    arg_e1 = EventArg(b1.get_event())
    arg_e2 = EventArg(b2.get_event())

    args = KernelArguments(k, arg2, arg1, arg_sx, arg_sy, arg_e1, arg_e2)

    b1.write(frames_matrix.tobytes(), frames_matrix_size)
    b2.read(out_matrix, out_matrix_size)

    end_ev = ctx.start_kernel(k, args)

    end_ev.wait()

actual = np.frombuffer(out_matrix, dtype=np.ubyte).reshape(4, out_frame_size)

print("Saving gif...")
[gif_saver.add_frame(actual[i].tobytes(), i+1) for i in range(0, 4)]
gif_saver.save("testgif.gif")
print("Saved")






