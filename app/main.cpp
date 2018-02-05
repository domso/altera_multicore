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
		for (volatile int i = 0; i < 100000; i++) {
	
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

		class lcd_display {
		public:
			void print(const char* c) {
				int position = 0;
				for (int i = 0; c[i] != 0 && position < 32; i++) {
					if (c[i] == '\n') {
						while ((position & 15) != 0) {							
							m_data = (position << 8) + ' ';
							position++;
						}
					} else {
						m_data = (position << 8) + c[i];
						position++;
					}
				}
			}

			void print(const char* c, const int n) {
				int position = 0;
				for (int i = 0; c[i] != 0 && i < n && position < 32; i++) {
					if (c[i] == '\n') {
						while ((position & 15) != 0) {							
							m_data = (position << 8) + ' ';
							position++;
						}
					} else {
						m_data = (position << 8) + c[i];
						position++;
					}
				}
			}

			void reset() {
				for (int i = 0; i < 32; i++) {
					m_data = ' ';
				}
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

	namespace lcd_display {
		static driver::lcd_display* const display = (driver::lcd_display*)0xC0000050;
	}

	namespace leds {
		static driver::leds<18>* const red  = (driver::leds<18>*)0xC0000030;
		static driver::leds<9>* const green = (driver::leds<9>*)0xC0000040;
	}
}

namespace global {
	std::atomic<int> displayValueLeft;
	std::atomic<int> displayValueRight;
	util::barrier* barrier;
	std::atomic<int> startBarrier;
}

void red_beam() {
    while (true) {
	global::barrier->wait();
        for (int i = 0; i <= board::leds::red->size(); i++) {
	    board::leds::red->set(15U << i);
	    system::wait();
	}
	global::barrier->wait();
    }
}

void green_beam() {
    while (true) {
        for (int i = 1; i < board::leds::green->size() + 1; i++) {
	    board::leds::green->set((1U << i) - 1);
	    system::wait();
	}

	global::barrier->wait();
	global::barrier->wait();
    }
}

void producer() {
    while (true) {
	global::displayValueLeft.store(board::keys::switches->read());
    }
}

void consumer() {
    while (true) {
	int left = global::displayValueLeft.load();
	int right = global::displayValueRight.load();
	board::hex_display::port0->set(right);
	board::hex_display::port1->set(left);
    }
}

void counter() {
    while (true) {
	int left = global::displayValueLeft.load();
	int right = global::displayValueRight.load();

	if (right < left) {
		global::displayValueRight.compare_exchange_strong(right, right + 1, std::memory_order_relaxed);
	}

	if (global::displayValueLeft.load(std::memory_order_relaxed) < global::displayValueRight.load(std::memory_order_relaxed)) {
		global::displayValueRight.store(0, std::memory_order_relaxed);
	}	

	system::wait();
    }
}

int main() {
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
		default: {
				counter();
				break;
			 }

	}
}

extern "C"
int entry_cpp(const int coreID) {
    // All cores are synchronized at this moment!
    global::startBarrier.store(0);
    
    if (coreID == 0) {
	   
  	util::barrier barrierOnStack(2);
	global::barrier = &barrierOnStack;

	global::displayValueLeft.store(0);
	global::displayValueRight.store(0);

	global::startBarrier.fetch_add(1);
	
	const char* test = "Hallo Welt!\n~*~*~*~*~*~";

	board::lcd_display::display->print(test);
	
	main();
    }

    while (global::startBarrier.load() == 0) {}
    main();
}

