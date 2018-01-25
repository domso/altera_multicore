#ifndef util_barrier_h
#define util_barrier_h

#include <atomic>

namespace util {
/**
 * spin-lock barrier
 */
class barrier {
public:
	/**
	 * @param n: constructs a new barrier for n threads
	 */
	explicit barrier(const int n);

	barrier(const barrier& b) = delete;

	/**
	 * waits (spin-lock!) until n thread reached this call.
	 */
	void wait();

private:
	std::atomic<int> m_head;
	std::atomic<int> m_counter;
	const int m_size;
};
}

#endif
