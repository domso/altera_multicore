#include "msg_queue.h"

namespace util {

    msg_queue::msg_queue(unsigned char* buffer, const int size) : m_size(size / 2), m_data(buffer), m_start(0), m_end(0), m_commit(0), m_acquired(0) {

    }

    bool msg_queue::release(const int lastFree, const int sizeFree, int numTries) {
        int last, next;
        next = lastFree + sizeFree;
        next -= m_size * (next >= m_size);

        do {
            if (numTries == 0) {
                return false;
            }

            numTries -= numTries > 0;
            last = lastFree;
        } while (!m_start.compare_exchange_strong(last, next));

        return true;
    }

    int msg_queue::load(const int sizeLoad, int numTries) {
        int start, end, newStart, finalStart;

        do {
            if (numTries == 0) {
                return -1;
            }

            numTries -= numTries > 0;

            start = m_acquired.load();
            end = m_commit.load();
            end += m_size * (end < start);

            newStart = start + sizeLoad;
            finalStart = newStart - m_size * (newStart >= m_size);
        } while (newStart > end || !m_acquired.compare_exchange_strong(start, finalStart));

        return start;
    }

    bool msg_queue::commit(const int lastCommit, const int sizeCommit, int numTries) {
        int last, next;
        next = lastCommit + sizeCommit;
        next -= m_size * (next >= m_size);

        do {
            if (numTries == 0) {
                return false;
            }

            numTries -= numTries > 0;
            last = lastCommit;
        } while (!m_commit.compare_exchange_strong(last, next));

        return true;
    }

    int msg_queue::reserve(const int sizeStorage, int numTries) {
        int start, end, newEnd, finalEnd;

        do {
            if (numTries == 0) {
                return -1;
            }

            numTries -= numTries > 0;

            start = m_start.load();
            end = m_end.load();
            start += m_size * (start <= end);

            newEnd = end + sizeStorage;
            finalEnd = newEnd - m_size * (newEnd >= m_size);
        } while (newEnd >= start || !m_end.compare_exchange_strong(end, finalEnd));

        return end;
    }

    int msg_queue::size() const {
        return m_size - 64;
    }

    int msg_queue::usage() const {
        int result = m_end.load() - m_start.load();
        result += m_size * (result < 0);
        return result;
    }

    int msg_queue::acquired() const {
        int result = m_acquired.load() - m_start.load();
        result += m_size * (result < 0);
        return result;
    }

    int msg_queue::available() const {
        int result = m_commit.load() - m_acquired.load();
        result += m_size * (result < 0);
        return result;
    }

    int msg_queue::uncommited() const {
        int result = m_end.load() - m_commit.load();
        result += m_size * (result < 0);
        return result;
    }

    int msg_queue::free() const {
        int result = m_start.load() - m_end.load();
        result += m_size * (result <= 0);
        return result - 64;
    }

}
