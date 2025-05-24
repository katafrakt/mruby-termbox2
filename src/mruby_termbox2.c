#include <mruby.h>
#include <mruby/array.h>
#include <mruby/hash.h>
#include <mruby/string.h>
#include <mruby/variable.h>
#define TB_IMPL
#include "termbox2.h"
#include "test_helpers.h"

static mrb_value mrb_tb2_init(mrb_state *mrb, mrb_value self) {
  tb_init();
  return mrb_nil_value();
}

static mrb_value mrb_tb2_shutdown(mrb_state *mrb, mrb_value self) {
  tb_shutdown();
  return mrb_nil_value();
}

static mrb_value mrb_tb2_present(mrb_state *mrb, mrb_value self) {
  tb_present();
  return mrb_nil_value();
}

static mrb_value mrb_tb2_clear(mrb_state *mrb, mrb_value self) {
  tb_clear();
  return mrb_nil_value();
}

static mrb_value mrb_tb2_print(mrb_state *mrb, mrb_value self) {
  int x;
  int y;
  const char *text;
  mrb_get_args(mrb, "i|i|z", &x, &y, &text);
  tb_print(x, y, 0, 0, text);
  return mrb_nil_value();
}

// converts TB_EVENT_* values to Ruby symbols
// Supported symbols are: :key, :mouse, :resize.
// If something unexpected happens, returns :unknown.
static mrb_value mrb_tb2_event_type_to_symbol(mrb_state *mrb, uint8_t type) {
  switch (type) {
  case TB_EVENT_KEY:
    return mrb_symbol_value(mrb_intern_lit(mrb, "key"));
  case TB_EVENT_MOUSE:
    return mrb_symbol_value(mrb_intern_lit(mrb, "mouse"));
  case TB_EVENT_RESIZE:
    return mrb_symbol_value(mrb_intern_lit(mrb, "resize"));
  default:
    return mrb_symbol_value(mrb_intern_lit(mrb, "unknown"));
  }
}

// This converts modifiers int (constants starting with TB_MOD_) to an array of
// symbols Supported symbols are: :alt, :ctrl, :shift, :motion
static mrb_value mrb_tb2_modifier_to_symbol(mrb_state *mrb, uint8_t mod) {
  mrb_value modifiers = mrb_ary_new(mrb);

  if (mod & TB_MOD_ALT) {
    mrb_ary_push(mrb, modifiers, mrb_symbol_value(mrb_intern_lit(mrb, "alt")));
  }
  if (mod & TB_MOD_CTRL) {
    mrb_ary_push(mrb, modifiers, mrb_symbol_value(mrb_intern_lit(mrb, "ctrl")));
  }
  if (mod & TB_MOD_SHIFT) {
    mrb_ary_push(mrb, modifiers,
                 mrb_symbol_value(mrb_intern_lit(mrb, "shift")));
  }
  if (mod & TB_MOD_MOTION) {
    mrb_ary_push(mrb, modifiers,
                 mrb_symbol_value(mrb_intern_lit(mrb, "motion")));
  }

  return modifiers;
}

static mrb_value mrb_tb2_poll_event(mrb_state *mrb, mrb_value self) {
  struct tb_event ev;
  tb_poll_event(&ev);

  struct RClass *termbox_mod = mrb_module_get(mrb, "Termbox2");
  mrb_value event_const = mrb_const_get(mrb, mrb_obj_value(termbox_mod),
                                        mrb_intern_lit(mrb, "Event"));

  // Convert the character to a Ruby string or nil if it's 0
  mrb_value character;
  if (ev.ch == 0) {
    character = mrb_nil_value();
  } else {
    character = mrb_str_new_cstr(mrb, (char[]){ev.ch, '\0'});
  }

  mrb_value args[] = {mrb_tb2_event_type_to_symbol(mrb, ev.type),
                      mrb_tb2_modifier_to_symbol(mrb, ev.mod),
                      mrb_fixnum_value(ev.key),
                      character,
                      mrb_fixnum_value(ev.w),
                      mrb_fixnum_value(ev.h),
                      mrb_fixnum_value(ev.x),
                      mrb_fixnum_value(ev.y)};

  mrb_value event =
      mrb_funcall_argv(mrb, event_const, mrb_intern_lit(mrb, "new"), 8, args);

  return event;
}

static mrb_value mrb_tb2_width(mrb_state *mrb, mrb_value self) {
  return mrb_fixnum_value(tb_width());
}

static mrb_value mrb_tb2_height(mrb_state *mrb, mrb_value self) {
  return mrb_fixnum_value(tb_height());
}

static mrb_value mrb_tb2_set_cell(mrb_state *mrb, mrb_value self) {
  mrb_int x, y;
  mrb_value ch_obj;
  mrb_int fg, bg;
  uint32_t ch = 0;
  char *ch_str;

  mrb_get_args(mrb, "iiSii", &x, &y, &ch_obj, &fg, &bg);

  if (mrb_string_p(ch_obj)) {
    ch_str = RSTRING_PTR(ch_obj);
    mrb_int ch_len = RSTRING_LEN(ch_obj);
    if (ch_len > 0) {
      ch = (uint32_t)(unsigned char)ch_str[0];
    }
  } else {
    mrb_raise(mrb, E_TYPE_ERROR, "String or Integer expected");
  }

  tb_set_cell((int)x, (int)y, ch, (uint32_t)fg, (uint32_t)bg);
  return mrb_nil_value();
}

static mrb_value mrb_tb2_set_cursor(mrb_state *mrb, mrb_value self) {
  mrb_int x, y;
  mrb_get_args(mrb, "ii", &x, &y);
  tb_set_cursor(x, y);
  return mrb_nil_value();
}

static mrb_value mrb_tb2_hide_cursor(mrb_state *mrb, mrb_value self) {
  tb_hide_cursor();
  return mrb_nil_value();
}

#define DEFINE_FORMAT_CONST(name)                                              \
  mrb_define_const(mrb, format_mod, #name, mrb_fixnum_value(TB_##name))
#define DEFINE_EVENT_FIELD(index, name)                                        \
  fields[index] = mrb_symbol_value(mrb_intern_lit(mrb, #name))

void mrb_mruby_termbox2_gem_init(mrb_state *mrb) {
  struct RClass *termbox_mod = mrb_define_module(mrb, "Termbox2");
  struct RClass *c_mod = mrb_define_module_under(mrb, termbox_mod, "C");

  mrb_value fields[8];
  DEFINE_EVENT_FIELD(0, type);
  DEFINE_EVENT_FIELD(1, mod);
  DEFINE_EVENT_FIELD(2, key);
  DEFINE_EVENT_FIELD(3, ch);
  DEFINE_EVENT_FIELD(4, w);
  DEFINE_EVENT_FIELD(5, h);
  DEFINE_EVENT_FIELD(6, x);
  DEFINE_EVENT_FIELD(7, y);

  mrb_value data =
      mrb_funcall_argv(mrb, mrb_obj_value(mrb_class_get(mrb, "Data")),
                       mrb_intern_lit(mrb, "define"), 8, fields);
  mrb_define_const(mrb, termbox_mod, "Event", data);

  mrb_define_class_method(mrb, c_mod, "init", mrb_tb2_init, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "shutdown", mrb_tb2_shutdown,
                          MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "present", mrb_tb2_present,
                          MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "clear", mrb_tb2_clear, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "print", mrb_tb2_print, MRB_ARGS_REQ(3));
  mrb_define_class_method(mrb, c_mod, "poll_event", mrb_tb2_poll_event,
                          MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "width", mrb_tb2_width, MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "height", mrb_tb2_height,
                          MRB_ARGS_NONE());
  mrb_define_class_method(mrb, c_mod, "set_cell", mrb_tb2_set_cell,
                          MRB_ARGS_REQ(5));
  mrb_define_class_method(mrb, c_mod, "set_cursor", mrb_tb2_set_cursor,
                          MRB_ARGS_REQ(2));
  mrb_define_class_method(mrb, c_mod, "hide_cursor", mrb_tb2_hide_cursor,
                          MRB_ARGS_NONE());

  // This cannot be desined in Ruby code, because integer values are assigned at
  // compile time.
  struct RClass *format_mod =
      mrb_define_module_under(mrb, termbox_mod, "Format");

  DEFINE_FORMAT_CONST(BOLD);
  DEFINE_FORMAT_CONST(UNDERLINE);
  DEFINE_FORMAT_CONST(REVERSE);
  DEFINE_FORMAT_CONST(ITALIC);
  DEFINE_FORMAT_CONST(BLINK);
  DEFINE_FORMAT_CONST(DIM);
  DEFINE_FORMAT_CONST(BRIGHT);
  DEFINE_FORMAT_CONST(HI_BLACK);

  // Special case for TB_256_BLACK as it doesn't follow the naming convention
  mrb_define_const(mrb, format_mod, "TB_256_BLACK",
                   mrb_fixnum_value(TB_256_BLACK));
  // skipping deprecated constants starting with TB_TRUECOLOR_*

#ifdef TB_STRIKEOUT
  DEFINE_FORMAT_CONST(STRIKEOUT);
#endif

#ifdef TB_UNDERLINE_2
  DEFINE_FORMAT_CONST(UNDERLINE_2);
#endif

#ifdef TB_OVERLINE
  DEFINE_FORMAT_CONST(OVERLINE);
#endif

#ifdef TB_INVISIBLE
  DEFINE_FORMAT_CONST(INVISIBLE);
#endif

  mrb_init_termbox2_test_helpers(mrb);
}

void mrb_mruby_termbox2_gem_final(mrb_state *mrb) {}
