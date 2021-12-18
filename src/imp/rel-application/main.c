#include "sdk.h"

int a[5];
int b[]={5};

void main(void) {
    while(1) {
        a[0] += 1;
        b[0] += 1;
    }
    ada_configure(true, 3u);
    return;
}
