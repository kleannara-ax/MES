package project.common.task.shedlock;

@FunctionalInterface
public interface CrontabFunction {
    void runTask();
}