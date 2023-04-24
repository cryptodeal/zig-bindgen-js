#include <stddef.h>
#include <stdint.h>

void fl_init(void);
size_t fl_bytesUsed(void);
int fl_dtype(void* tensor);
int fl_dtypeFloat16(void);
void fl_destroyTensor(void* t, void* hint);


void fl_dispose(void* t);
size_t fl_elements(void *t);
void *fl_asContiguousTensor(void *t);
void *fl_tensorFromFloat32Buffer(int64_t numel, float *ptr);
float *fl_float32Buffer(void *t);