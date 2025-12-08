/*
 * Copyright (c) 2010-2025 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#pragma once

#include "scheduledevent.h"
#include <framework/util/spinlock.h>

enum class TaskGroup : int8_t
{
    NoGroup = -1, // is outside the context of the dispatcher
    Serial,
    GenericParallel,
    Last
};

enum class DispatcherType : uint8_t
{
    NoType,
    Event,
    AsyncEvent,
    ScheduledEvent,
    CycleEvent,
    DeferEvent
};

struct DispatcherContext
{
    bool isGroup(const TaskGroup _group) const {
        return group == _group;
    }

    bool isAsync() const {
        return type == DispatcherType::AsyncEvent;
    }

    auto getGroup() const {
        return group;
    }

    auto getType() const {
        return type;
    }

private:
    void reset() {
        group = TaskGroup::NoGroup;
        type = DispatcherType::NoType;
    }

    DispatcherType type = DispatcherType::NoType;
    TaskGroup group = TaskGroup::NoGroup;

    friend class EventDispatcher;
};

/**
 * Initialize the event dispatcher and prepare internal thread/task structures.
 */
 
/**
 * Shut down the dispatcher and stop processing new or pending events.
 */
 
/**
 * Poll and process pending immediate, deferred, and scheduled events.
 */
 
/**
 * Schedule an immediate event to be executed as soon as the dispatcher processes events.
 * @param callback Function to be executed for the event.
 * @returns EventPtr Handle to the scheduled event.
 */
 
/**
 * Schedule a deferred event that will be executed during the dispatcher's deferred-event processing phase.
 * @param callback Function to be executed for the deferred event.
 */
 
/**
 * Schedule a one-shot event to be executed after the specified delay.
 * @param callback Function to be executed when the scheduled time is reached.
 * @param delay Delay in milliseconds before the event is executed.
 * @returns ScheduledEventPtr Handle to the scheduled event.
 */
 
/**
 * Schedule a repeating event to be executed with the specified interval between executions.
 * @param callback Function to be executed each cycle.
 * @param delay Interval in milliseconds between event executions.
 * @returns ScheduledEventPtr Handle to the repeating scheduled event.
 */
 
/**
 * Access the current thread's dispatcher context.
 * @returns const DispatcherContext& Reference to the thread-local dispatcher context.
 */
 
/**
 * Return the thread-local task structure for the current thread.
 * @returns const std::unique_ptr<EventDispatcher::ThreadTask>& Reference to the current thread's ThreadTask.
 */
 
/**
 * Execute `inserter` while holding the current thread's ThreadTask lock and return its result if any.
 * @tparam Result The return type produced by `inserter` (defaults to void).
 * @tparam Inserter Callable type that accepts a `const std::unique_ptr<ThreadTask>&`.
 * @param inserter Callable invoked with the current thread task under lock.
 * @returns Result The value returned by `inserter` when `Result` is not void.
 */
class EventDispatcher
{
public:
    EventDispatcher() = default;

    void init();
    void shutdown();
    void poll();

    EventPtr addEvent(const std::function<void()>& callback);
    void deferEvent(const std::function<void()>& callback);
    ScheduledEventPtr scheduleEvent(const std::function<void()>& callback, int delay);
    ScheduledEventPtr cycleEvent(const std::function<void()>& callback, int delay);

    const auto& context() const {
        return dispacherContext;
    }

private:
    thread_local static DispatcherContext dispacherContext;

    /**
     * Per-thread state for pending task processing used by the event dispatcher.
     *
     * Represents the lifecycle stage of thread-local task aggregation so the dispatcher
     * can coordinate adding and merging of events between threads.
     */
    enum class ThreadTaskEventState
    {
        ADDING,
        ADDED,
        MERGING,
        MERGED
    };

    // Thread Events
    struct ThreadTask
    {
        ThreadTask() {
            events.reserve(2000);
            scheduledEventList.reserve(2000);
        }

        std::vector<EventPtr> events;
        std::vector<Event> deferEvents;
        std::vector<ScheduledEventPtr> scheduledEventList;
        SpinLock lock;
    };

    inline void mergeEvents();
    inline void executeEvents();
    inline void executeDeferEvents();
    inline void executeScheduledEvents();

    const std::unique_ptr<ThreadTask>& getThreadTask() const {
        return m_threads[stdext::getThreadId() % m_threads.size()];
    }

    template<typename Result = void, typename Inserter>
    Result pushThreadTask(Inserter inserter) {
        const auto& thread = getThreadTask();
        SpinLock::Guard guard(thread->lock);
        if constexpr (std::is_void_v<Result>) {
            inserter(thread);
        } else {
            Result result = inserter(thread);
            return result;
        }
    }

    size_t m_pollEventsSize{};
    bool m_disabled{ false };

    std::vector<std::unique_ptr<ThreadTask>> m_threads;

    // Main Events
    std::vector<EventPtr> m_eventList;
    std::vector<Event> m_deferEventList;
    phmap::btree_multiset<ScheduledEventPtr, ScheduledEvent::Compare> m_scheduledEventList;
};

extern EventDispatcher g_dispatcher, g_textDispatcher, g_mainDispatcher;
extern int16_t g_mainThreadId;
extern int16_t g_eventThreadId;