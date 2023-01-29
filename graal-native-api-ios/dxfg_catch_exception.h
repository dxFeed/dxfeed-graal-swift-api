// SPDX-License-Identifier: MPL-2.0

#ifndef DXFEED_GRAAL_NATIVE_API_CATCH_EXCEPTION_H_
#define DXFEED_GRAAL_NATIVE_API_CATCH_EXCEPTION_H_

#ifdef __cplusplus
extern "C" {
#    include <cstdint>
#else
#    include <stdint.h>
#endif

#include "graal_isolate.h"

typedef struct dxfg_exception_t {
    const char *className;
    const char *message;
    const char *stackTrace;
} dxfg_exception_t;

dxfg_exception_t* dxfg_get_and_clear_thread_exception_t(graal_isolatethread_t *thread);
void dxfg_Exception_release(graal_isolatethread_t *thread, dxfg_exception_t *exception);

#ifdef __cplusplus
}
#endif

#endif // DXFEED_GRAAL_NATIVE_API_CATCH_EXCEPTION_H_
