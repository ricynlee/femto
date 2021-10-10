#include "femto.h"
#include "ut.h"

int main(){
    int a = 5;

    if (a==5)
        trigger_pass();
    else
        trigger_fail();

    return 0;
}
