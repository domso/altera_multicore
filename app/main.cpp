#include <atomic>
#include <stdint.h>
#include "barrier.hpp"

/* Startup code: do not alter! */
asm(
    ".section \".entry\"\n\t"
    ".global _start\n\t"
    "_start:\n\t"

    "csrr a0, 0xf14\n\t"


    "lui x1, 0x80000\n\t"
    //"lr.w.sc x2, (x1)\n\t"
    //"sc.w.sc x3, a0, (x1)\n\t"

    //"lw x4, 0(x1)\n\t"




    "add a1, x0, 1024\n\t"
    "sll a2, a1, a0\n\t"
    "lui a3, 0x80000\n\t"
    "add sp, a2, a3\n\t"

    "jal entry_cpp\n\t"
    
    

    "exit:\n\t"
    "add x1, x0, a0\n\t"
   "j exit\n\t"

);

namespace system {
	void wait() {
		for (int i = 0; i < 100000; i++) {
	
		}
	}

	static inline int coreID() {
		int result;
		asm("csrr %0, 0xf14" : "=r"(result));

		return result;
	}
}

namespace board {
	namespace driver {
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
		
			volatile int32_t m_data;
		};

		template <int bitCount>
		class leds {
		public:
			void set(const int32_t data) {
				m_data = data;
			}

			int size() const {
				return bitCount;
			}
		private:
			volatile int32_t m_data;
		};

		template <int bitCount>
		class switches {
		public:
			int32_t read() const {
				return m_data;
			}

			int size() const {
				return bitCount;
			}
		private:
			volatile int32_t m_data;
		};
	}

	namespace keys {
		static const driver::switches<18>* const switches = (driver::switches<18>*)0xC0000000;
	}

	namespace hex_display {
		static driver::seven_segment_display* const port0 = (driver::seven_segment_display*)0xC0000010;
		static driver::seven_segment_display* const port1 = (driver::seven_segment_display*)0xC0000020;
	}

	namespace leds {
		static driver::leds<18>* const red  = (driver::leds<18>*)0xC0000030;
		static driver::leds<9>* const green = (driver::leds<9>*)0xC0000040;
	}
}

namespace global {
	std::atomic<int> displayValue;
	util::barrier* barrier;
	std::atomic<int> startBarrier;
}

void red_beam() {
    while (true) {
        for (int i = 0; i < board::leds::red->size(); i++) {
	    board::leds::red->set(1U << i);
	    system::wait();
	}
    }
}

void green_beam() {
    while (true) {
        for (int i = 1; i < board::leds::green->size() + 1; i++) {
	    board::leds::green->set((1U << i) - 1);
	    system::wait();
	}
    }
}

void producer() {
    while (true) {
	    global::displayValue.store(board::keys::switches->read());
    }
}

void consumer() {
    while (true) {
	int current = global::displayValue.load();
	board::hex_display::port0->set(current);
	board::hex_display::port1->set(current / 10000);
    }
}

int main() {
	global::barrier->wait();
	switch (system::coreID()) {
		case 0 : {
				producer();			
				 break;
			 }
		case 1 : {
				consumer();
				 break;
			 }
		case 2 : {
				red_beam();
				 break;
			 }
		case 3 : {
				green_beam();		
				 break;
			 }

	}
}

extern "C"
int entry_cpp(const int coreID) {
    // All cores are synchronized at this moment!
	global::startBarrier.store(0);
    
    if (coreID == 0) {
  	util::barrier barrierOnStack(4);
	global::barrier = &barrierOnStack;

	global::startBarrier.fetch_add(1);
	main();
    }

    while (global::startBarrier.load() == 0) {}
    main();
}

