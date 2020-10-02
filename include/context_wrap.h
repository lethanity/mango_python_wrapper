#ifndef CONTEXT_WRAP_H
#define CONTEXT_WRAP_H

# include "context.h"

namespace mango {

	inline Context & add_kernel(Context& ctx, std::shared_ptr<Kernel> k){
		ctx += k;
		return ctx;
	}

	inline Context & add_buffer(Context& ctx, std::shared_ptr<Buffer> b){
		ctx += b;
		return ctx;
	}

	inline Context & add_event(Context& ctx, std::shared_ptr<Event> e){
		ctx += e;
		return ctx;
	}

}
#endif /* CONTEXT_WRAP_H */