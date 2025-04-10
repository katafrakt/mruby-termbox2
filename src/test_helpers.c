#include <mruby.h>
#include <mruby/array.h>
#include <mruby/string.h>
#include <stdlib.h>
#include <pty.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>
#include <errno.h>
#include <stdio.h>
#include "termbox2.h"

static struct {
    int master_fd;
    int slave_fd;
    bool initialized;
} test_pty = {-1, -1, false};

static mrb_value mrb_tb2_test_init_pty(mrb_state *mrb, mrb_value self) {
    if (test_pty.initialized) {
        fprintf(stderr, "Cleaning up previous PTY instance\n");
        tb_shutdown();
        close(test_pty.master_fd);
        close(test_pty.slave_fd);
        test_pty.initialized = false;
    }

    mrb_int width, height;
    mrb_get_args(mrb, "ii", &width, &height);
    
    struct winsize ws = {
        .ws_row = height,
        .ws_col = width,
        .ws_xpixel = 0,
        .ws_ypixel = 0
    };
    
    int pty_result = openpty(&test_pty.master_fd, &test_pty.slave_fd, NULL, NULL, &ws);
    if (pty_result == -1) {
        mrb_raise(mrb, E_RUNTIME_ERROR, "Failed to open pseudoterminal");
    }
    
    // Set non-blocking mode on master
    int flags = fcntl(test_pty.master_fd, F_GETFL, 0);
    fcntl(test_pty.master_fd, F_SETFL, flags | O_NONBLOCK);
    
    // Initialize termbox with our slave PTY
    int tb_result = tb_init_fd(test_pty.slave_fd);
    if (tb_result != 0) {
        close(test_pty.master_fd);
        close(test_pty.slave_fd);
        mrb_raise(mrb, E_RUNTIME_ERROR, "Failed to initialize Termbox with PTY");
    }

    test_pty.initialized = true;
    return mrb_nil_value();
}

static mrb_value mrb_tb2_test_read_output(mrb_state *mrb, mrb_value self) {
    if (!test_pty.initialized) {
        mrb_raise(mrb, E_RUNTIME_ERROR, "PTY not initialized");
    }
    
    // Small delay to allow output to be written
    usleep(10000);  // 10ms delay
    
    char buf[1024];
    ssize_t total_read = 0;
    ssize_t n;
    
    // Try to read multiple times to get all available data
    do {
        n = read(test_pty.master_fd, buf + total_read, sizeof(buf) - 1 - total_read);
        if (n > 0) {
            total_read += n;
        }
    } while (n > 0 && total_read < sizeof(buf) - 1);
    
    if (total_read > 0) {
        buf[total_read] = '\0';
        return mrb_str_new_cstr(mrb, buf);
    }
    
    return mrb_str_new_cstr(mrb, "");
}

static mrb_value mrb_tb2_test_cleanup(mrb_state *mrb, mrb_value self) {
    if (test_pty.initialized) {
        tb_shutdown();
        close(test_pty.master_fd);
        close(test_pty.slave_fd);
        test_pty.initialized = false;
    }
    return mrb_nil_value();
}

void mrb_init_termbox2_test_helpers(mrb_state *mrb) {
    struct RClass *test_mod = mrb_define_module(mrb, "Termbox2Test");
    
    mrb_define_module_function(mrb, test_mod, "init_pty", mrb_tb2_test_init_pty, MRB_ARGS_REQ(2));
    mrb_define_module_function(mrb, test_mod, "read_output", mrb_tb2_test_read_output, MRB_ARGS_NONE());
    mrb_define_module_function(mrb, test_mod, "cleanup", mrb_tb2_test_cleanup, MRB_ARGS_NONE());
}
