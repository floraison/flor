

module Flor::Instructions

#static char exe_val(fdja_value *node, fdja_value *exe)
#{
#  fdja_value *atts = attributes(node, exe);
#
#  fdja_value *val = fdja_l(atts, "_0");
#  if (val == NULL) val = fdja_v("null");
#
#  fdja_pset(exe, "payload.ret", fdja_clone(val));
#
#  fdja_free(atts);
#
#  return 'v'; // over
#}
  def self.exe_val(node, msg)

    :over
  end
end

