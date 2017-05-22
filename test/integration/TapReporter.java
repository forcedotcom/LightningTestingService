package test.integration;

import java.util.*;
import org.junit.runner.Description;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import org.junit.runner.notification.RunListener;

public class TapReporter extends RunListener {
    int testCount = 0;
    Map<String, Boolean> currentTest = new HashMap<String, Boolean>();

    public void testRunStarted(Description description) throws Exception {
        System.out.println("1.." + description.testCount());
    }

    public void testStarted(Description description) throws Exception {
        currentTest.put(description.getMethodName(), true);
    }

    public void testFinished(Description description) throws Exception {
        if (currentTest.get(description.getMethodName())) {
            System.out.println("ok " + (++testCount) + " " + description.getMethodName());
        }
    }

    public void testFailure(Failure failure) throws Exception {
        Description description = failure.getDescription();
        currentTest.put(description.getMethodName(), false);
        System.out.println("not ok " + (++testCount) + " " + description.getMethodName());
        System.out.println("    #" + failure.getMessage());
    }
}
