#ifndef TASK_GRAPH_WRAP_H
#define TASK_GRAPH_WRAP_H

# include "task_graph.h"

namespace mango {

    inline TaskGraph & add_kernel(TaskGraph &tg, std::shared_ptr<Kernel> kernel) {
        tg += kernel;
        return tg;
    }
    
    inline TaskGraph & remove_kernel(TaskGraph &tg, std::shared_ptr<Kernel> kernel) {
        tg -= kernel;
        return tg;
    }

    inline TaskGraph & add_buffer(TaskGraph &tg, std::shared_ptr<Buffer> buffer) {
        tg += buffer;
        return tg;
    }

    inline TaskGraph & remove_buffer(TaskGraph &tg, std::shared_ptr<Buffer> buffer) {
        tg -= buffer;
        return tg;
    }

    inline TaskGraph & add_event(TaskGraph &tg, std::shared_ptr<Event> event) {
        tg += event;
        return tg;
    }

    inline TaskGraph & remove_event(TaskGraph &tg, std::shared_ptr<Event> event) {
        tg -= event;
        return tg;
    }

}

#endif /* TASK_GRAPH_WRAP_H */