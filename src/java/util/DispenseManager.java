package util;

import java.util.concurrent.ConcurrentLinkedQueue;

public class DispenseManager {

    public static class DispenseCommand {
        private final String orderId;
        private final String slotCode;
        private final int turns;
        private final long createdAt;

        public DispenseCommand(String orderId, String slotCode, int turns) {
            this.orderId = orderId;
            this.slotCode = slotCode;
            this.turns = turns;
            this.createdAt = System.currentTimeMillis();
        }

        public String getOrderId() {
            return orderId;
        }

        public String getSlotCode() {
            return slotCode;
        }

        public int getTurns() {
            return turns;
        }

        public long getCreatedAt() {
            return createdAt;
        }
    }

    private static final ConcurrentLinkedQueue<DispenseCommand> queue = new ConcurrentLinkedQueue<DispenseCommand>();

    public static void addCommand(String orderId, String slotCode, int turns) {
        if (slotCode != null && !slotCode.trim().isEmpty()) {
            queue.offer(new DispenseCommand(orderId, slotCode.trim(), turns > 0 ? turns : 1));
        }
    }

    public static DispenseCommand pollCommand() {
        return queue.poll();
    }

    public static int getPendingCount() {
        return queue.size();
    }

    public static void clear() {
        queue.clear();
    }
}
