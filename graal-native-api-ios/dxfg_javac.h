// SPDX-License-Identifier: MPL-2.0

#ifndef DXFEED_GRAAL_NATIVE_API_JAVAC_H_
#define DXFEED_GRAAL_NATIVE_API_JAVAC_H_

#ifdef __cplusplus
extern "C" {
#    include <cstdint>
#else
#    include <stdint.h>
#endif

#include "graal_isolate.h"

/** @defgroup Javac
 *  @{
 */

typedef struct dxfg_java_object_handler {
    void *java_object_handle;
} dxfg_java_object_handler;

typedef struct dxfg_list {
    int32_t size;
    void **elements;
} dxfg_list;

typedef struct dxfg_java_object_handler_list {
    int32_t size;
    dxfg_java_object_handler **elements;
} dxfg_java_object_handler_list;

typedef struct dxfg_executor_t {
    dxfg_java_object_handler handler;
} dxfg_executor_t;

// free the memory occupied by the с data structure and release the reference to the java object
int dxfg_JavaObjectHandler_release(graal_isolatethread_t *thread, dxfg_java_object_handler*);

// free the memory occupied by the с data structure (list and all elements) and release the reference to the java object for all elements
int dxfg_CList_JavaObjectHandler_release(graal_isolatethread_t *thread, dxfg_java_object_handler_list*);

/** @} */ // end of Javac

#ifdef __cplusplus
}
#endif

#endif // DXFEED_GRAAL_NATIVE_API_JAVAC_H_




