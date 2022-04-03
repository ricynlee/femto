#include "femto.h"
#include "ut.h"

void main(void){
    int a = 5;

    if (a==5)
        trigger_pass();
    else
        trigger_fail();
}
