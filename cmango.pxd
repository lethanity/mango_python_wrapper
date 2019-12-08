from libc.stdint cimport uint32_t, uint16_t

cdef extern from "mango.h":

    ctypedef uint32_t mango_kernel_t
    ctypedef uint32_t mango_buffer_t
    ctypedef uint32_t mango_event_t

    ctypedef struct kernelfunction:
        pass
    ctypedef struct mango_task_graph_t:
        pass
    ctypedef struct mango_args_t:
        pass
    ctypedef struct mango_arg_t:
        pass

    mango_exit_t mango_init(const char *application_name, const char *recipe)
    mango_exit_t mango_release()
    kernelfunction *mango_kernelfunction_init()
    mango_exit_t mango_load_kernel(const char *kname, kernelfunction *kernel, mango_unit_type_t unit, filetype t)
    # TODO variadic function
    mango_kernel_t mango_register_kernel(uint32_t kernel_id, kernelfunction *kernel, unsigned int nbuffers_in, unsigned int nbuffers_out, ...)

    void mango_deregister_kernel(mango_kernel_t kernel)
    # TODO variadic function
    mango_buffer_t mango_register_memory(uint32_t buffer_id, size_t size, mango_buffer_type_t mode, unsigned int nkernels_in, unsigned int nkernels_out, ...)

    void mango_deregister_memory(mango_buffer_t mem)
    # TODO variadic function
    mango_event_t mango_register_event(unsigned int nkernels_in, unsigned int nkernels_out, ...)

    void mango_deregister_event(mango_event_t event)
    mango_event_t mango_get_buffer_event(mango_buffer_t buffer)
    mango_task_graph_t *mango_task_graph_vcreate(mango_kernel_t **kernels, mango_buffer_t **buffers, mango_event_t **events)
    # TODO variadic function
    mango_task_graph_t *mango_task_graph_create(int k, int b, int e, ...)

    void mango_task_graph_destroy(mango_task_graph_t *task_graph)
    void mango_task_graph_destroy_all(mango_task_graph_t *task_graph)
    mango_task_graph_t *mango_task_graph_add_kernel(mango_task_graph_t *tg, mango_kernel_t *kernel)
    mango_task_graph_t *mango_task_graph_remove_kernel(mango_task_graph_t *tg, mango_kernel_t *kernel)
    mango_task_graph_t *mango_task_graph_add_buffer(mango_task_graph_t *tg, mango_buffer_t *buffer)
    mango_task_graph_t *mango_task_graph_remove_buffer(mango_task_graph_t *tg, mango_buffer_t *buffer)
    mango_task_graph_t *mango_task_graph_add_event(mango_task_graph_t *tg, mango_event_t *event)
    mango_task_graph_t *mango_task_graph_remove_event(mango_task_graph_t *tg, mango_event_t *event)
    mango_exit_t mango_resource_allocation(mango_task_graph_t *tg)
    void mango_resource_deallocation(mango_task_graph_t *tg)
    void mango_wait(mango_event_t e)
    void mango_wait_state(mango_event_t e, uint32_t state)
    void mango_write_synchronization(mango_event_t event, uint32_t value)
    uint32_t mango_read_synchronization(mango_event_t event)
    uint32_t mango_lock(mango_event_t e)
    mango_event_t mango_write(const void *GN_buffer, mango_buffer_t HN_buffer, mango_communication_mode_t mode, size_t global_size)
    mango_event_t mango_read(void *GN_buffer, mango_buffer_t HN_buffer, mango_communication_mode_t mode, size_t global_size)
    mango_arg_t *mango_arg(mango_kernel_t kernel, const void *value, size_t size, mango_buffer_type_t t)
    # TODO variadic function
    mango_args_t *mango_set_args(mango_kernel_t kernel, int argc, ...)

    mango_event_t mango_start_kernel(mango_kernel_t kernel, mango_args_t *args, mango_event_t event)
    uint32_t mango_get_unit_id(mango_kernel_t kernel)
    uint16_t mango_get_max_nr_buffers()
    mango_unit_type_t mango_get_unit_arch(mango_kernel_t kernel)


cdef extern from "mango_types_c.h":

    ctypedef enum mango_exit_t:
        SUCCESS
        ERR_INVALID_VALUE
        ERR_INVALID_TASK_ID
        ERR_INVALID_KERNEL
        ERR_FEATURE_NOT_IMPLEMENTED
        ERR_INVALID_KERNEL_FILE
        ERR_UNSUPPORTED_UNIT
        ERR_OUT_OF_MEMORY
        ERR_SEM_FAILED
        ERR_MMAP_FAILED
        ERR_FOPEN
        ERR_OTHER 

    ctypedef enum mango_event_status_t:
        LOCK
        READ
        WRITE
        END_FIFO_OPERATION 

    ctypedef enum filetype:
        UNKNOWN_KERNEL_SOURCE_TYPE
        BINARY
        HARDWARE
        STRING
        SOURCE

    ctypedef enum mango_buffer_type_t:
        NONE
        FIFO
        BUFFER
        SCALAR
        EVENT

    ctypedef enum mango_unit_type_t:
        PEAK
        NUP
        DCT
        GN
        GPGPU
        ARM
        STOP

    ctypedef enum mango_communication_mode_t:
        DIRECT
        BURST



