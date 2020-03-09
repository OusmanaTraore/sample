package com.gtm.devops;

import static org.junit.Assert.assertTrue;
import com.gtm.devops.controller.LoginController;
import org.junit.Test;

public class DevOpsApplicationTests {

    @Test
    public void testLoginController() {
        final LoginController loginController = new LoginController();
		final String result = loginController.loginMessage();
        assertTrue(result.length() > 0);
    }

}