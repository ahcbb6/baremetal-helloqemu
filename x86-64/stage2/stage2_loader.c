/*
   Borrowed from https://github.com/Codetector1374/GuideOS (no license specified)
*/

unsigned char* current_binary = ((unsigned char*) 0x10000);
unsigned char* target_binary = ((unsigned char*) 0x100000);

void (*entry) (void) = (void (*) (void))0x100000;

__attribute__((noreturn))
void stage2_cmain(void) {
    for (unsigned int i = 0; i < 256 * 1024; ++i) {
        target_binary[i] = current_binary[i];
    }
    entry();
    for(;;) {
    }
}
