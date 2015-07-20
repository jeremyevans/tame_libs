#include <ruby.h>
#include <sys/tame.h>

static VALUE cTameFlags;

static VALUE rb_tame(int argc, VALUE *argv, VALUE self) {
  /* required for ruby to work */
  int tame_flags = TAME_STDIO;
  int i;
  VALUE v;

  for(i = 0; i < argc; i++) {
    v = rb_hash_aref(cTameFlags, argv[i]);
    if (RTEST(v) == 0) {
      rb_raise(rb_eArgError, "unsupported tame argument");
    }
    tame_flags |= FIX2INT(v);
  }

  tame(tame_flags);
  return Qnil;
}

void Init_tame(void) {
  VALUE cTame;
  cTame = rb_define_module("Tame");
  rb_define_method(cTame, "tame", rb_tame, -1);
  rb_extend_object(cTame, cTame);

  cTameFlags = rb_hash_new();
  rb_global_variable(&cTameFlags);
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("abort")), INT2FIX(TAME_ABORT));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("cmsg")), INT2FIX(TAME_CMSG));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("cpath")), INT2FIX(TAME_CPATH));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("dns")), INT2FIX(TAME_DNS));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("getpw")), INT2FIX(TAME_GETPW));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("inet")), INT2FIX(TAME_INET));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("ioctl")), INT2FIX(TAME_IOCTL));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("proc")), INT2FIX(TAME_PROC));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("rpath")), INT2FIX(TAME_RPATH));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("tmppath")), INT2FIX(TAME_TMPPATH));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("unix")), INT2FIX(TAME_UNIX));
  rb_hash_aset(cTameFlags, ID2SYM(rb_intern("wpath")), INT2FIX(TAME_WPATH));
  rb_hash_freeze(cTameFlags);
}
