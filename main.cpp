/* Test programm to print a decimal counter on the 7-segment display */

#include <atomic>
#include <stdint.h>

/* Startup code: do not alter! */
asm(
    ".section \".entry\"\n\t"
    ".global _start\n\t"
    "_start:\n\t"

"csrr a0, 0xf14\n\t"

"add a1, x0, 1024\n\t"
"sll a2, a1, a0\n\t"
"lui a3, 0x80000\n\t"
"add sp, a2, a3\n\t"

"jal entry_cpp\n\t"
"exit:\n\t"
"add x1, x0, a0\n\t"
"j exit\n\t"

);

static const char digit[16] = {
	 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,
	 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71,
}; 


class seven_segment_display {
public:
	void set(const int32_t number) {
		m_data = convert_digit(number);
	}

private:
	int32_t convert_digit(const int32_t v) {
		return ~(
	        (digit[(v/1000) % 10] << 24) |
        	(digit[(v/100) % 10] << 16) |
	        (digit[(v/10) % 10] << 8) |
        	digit[v % 10]);
	}
	
	int32_t m_data;
};



void sleep() {
	for (int i = 0; i < 100000; i++) {

	}
}

std::atomic<int> counter;

//constexpr const seven_segment_display* outputDisplay = reinterpret_cast<const seven_segment_display*>(0xC0000000); 


extern "C"
int entry_cpp(const int coreID) {
    counter.store(0);
  
    seven_segment_display* outputDisplay = reinterpret_cast<seven_segment_display*>(0xC0000000); 

    if (coreID == 1) {
    	while(true) {
	    counter.fetch_add(1);
	    sleep();
	}
    }

    if (coreID == 0) {
	while (true) {
		outputDisplay->set(counter.load());
	}
    }
}


